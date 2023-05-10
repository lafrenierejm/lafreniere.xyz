---
title: "Fun with Static Types in Python"
date: 2023-05-02T23:50:00-05:00
draft: false
---

<hr>

{{< hint info >}}
This post was originally written to accompany a lightning talk I gave to the engineering department at Renaissance Learning, my employer.
All code examples in this post assume Python 3.9 or later.
{{< /hint >}}

## Basics

1. The syntax and semantics of Python's type hints were first defined in [PEP 484](https://peps.python.org/pep-0484/).
1. Python's steering committee has (multiple times) reaffirmed that it has no intentions to make static type checking mandatory as part of the language itself;
   [duck typing](https://en.wikipedia.org/wiki/Duck_typing) is here to stay.
1. The first version of Python to support type hints was [Python 3.5](https://docs.python.org/3.5/whatsnew/3.5.html), which was released 2015-09.
1. Releases since 3.5 preserved backwards compatibility but continued making the type system more powerful and its syntax more flexible.

## Exhaustiveness Checking

Exhaustiveness checking means that the type checker guarantees that all possible cases are accounted for.
In my experience, this is most useful when used in combination with enumerator (enum) classes.

Lets say we have an static set of environments our code could be running in.
We will define an enum to describe those potential environments:

```python
from enum import Enum

class Environment(str, Enum):
    PROD = "prod"
    DEV = "dev"
    LOCAL = "local"
```

And also define a function that performs different logic based on which environment we are in:

```python
def environment_specific_logic(env: Environment) -> str:
    if env is Environment.PROD:
        return "red"
    else:
        return "green"
```

But what happens if the organization happens needs to add a fourth environment, say `STAGING`?

1. We can trivially add a new member to `Environment`.
1. When calling `environment_specific_logic` with `Environment.STAGING`:
   1. The type checker will not complain; the types all still align.
   1. No exceptions will be raised at runtime.
   1. `STAGING` will just silently caught by the `else` branch and `"green"` will be returned.

However, we can get the type checker to begin performing exhaustiveness checking for us if we give it just a _little_ more help.
Having exhaustiveness checking in place will ensure that we update our function whenever `Environment` changes.

```python
from enum import Enum
from typing import NoReturn

def assert_never(arg: NoReturn) -> NoReturn:
    raise AssertionError("Expected code to be unreachable")

def environment_specific_logic(env: Environment) -> str:
    # Explicitly handle all of the known cases.
    if env is Environment.PROD:
        return "red"
    elif env is Environment.DEV or env is Environment.LOCAL:
        return "yellow"
    # Add a catch-all that the type checker will complain about if its reachable.
    else:
        return assert_never(env)
```

Now if a `STAGING` member were to be added to `Environment`, the type checker would complain that we're attempting to call `assert_never` with an instance of `Environment` when `NoReturn` was the expected argument type.
Even better, the type checker would be able to tell us that it's the `STAGING` member of `Environment` specifically that is falling through to the `assert_never` call.

## Function Overloading

Often the we will want to have a single function that supports multiple, distinct combinations of types.
For a motivating example, let's build on the above example of multiple environments and add a few additional caveats:

- Assume the environments run in AWS and each environment resides in its own account.
- We want a single function that can get us one of a set of AWS service clients via the [aiobotocore library](https://github.com/aio-libs/aiobotocore).
  - This may be the case when e.g. the logic for determining which cross-account role to assume is complex enough that we don't want to repeat it throughout a codebase.
- The services we want to be able to form clients for are ECR and ECS.

We can use `typing.overload` to let the type checker know the specific class that will be returned for a given service:

```python
from __future__ import annotation # postpone evaluation of type hints (PEP 563)

from contextlib import asynccontextmanager
from typing import TYPE_CHECKING

from aiobotocore.session import AioSession

from .environment import Environment # this is the same enum we defined earlier

if TYPE_CHECKING:
    # Imports needed only for type checking go here.
    # Since they are inside the `if`, they will not be imported at runtime.
    from collections.abc import AsyncIterator
    from contextlib import AbstractAsyncContextManager
    from typing import Literal, Union, overload
    from types_aiobotocore_ecr import ECRClient
    from types_aiobotocore_ecs import ECSClient


if TYPE_CHECKING:
    # We perform our function overloading inside this `if` block so it will be skipped at runtime.

    @overload
    def aws_client(
        session: AioSession,
        service: Literal["ecr"],
        environment: Environment
    ) -> AbstractAsyncContextManager[ECRClient]:
        # These three periods (roughly forming an ellipsis) _are_ part of the Python code.
        ...

    @overload
    def aws_client(
        session: AioSession,
        service: Literal["ecs"],
        environment: Environment
    ) -> AbstractAsyncContextManager[ECSClient]:
        # Again, the ellipsis is part of the actual code.
        ...


# Now we actually define the function.
# This is _not_ inside an `if TYPE_CHECKING` block, so it _will_ be seen at runtime.
@asynccontextmanager
async def aws_client(
    session: AioSession,
    service: Literal["ecr", "ecs"],
    environment: Environment,
) -> AsyncIterator[Union[ECRClient, ECSClient]]:
    if environment is Environment.LOCAL:
        async with session.create_client(service) as client:
            yield client
    # Handle the other Environment members.
```

## Runtime Benefits

Type hints are available at runtime.
This means that _regular Python code_ can inspect and use the information from those hints.
[Typer](https://typer.tiangolo.com/) is one library that takes advantage of that to compose low-code CLIs that are type checked at runtime.

Let's build a mock CLI to demonstrate.
The requirements:

- Mandatory environment (as defined earlier) with a default value of `LOCAL`.
- Optional `--verbose`/`-v` flag.

```python
from typing_extensions import Annotated

import typer

from .environment import Environment # this is the same enum we defined earlier

def main(
    env: Annotated[Environment, typer.Argument()] = Environment.LOCAL,
    verbose: Annotated[bool, typer.Option(help="Enable debug logging")] = False,
) -> None:
    print(f"{env=}, {verbose=}")


if __name__ == "__main__":
    typer.run(main)
```

Running that script with the Typer's built-in `--help` flag:

```shell
python -m python_static_types --help
```

…gives the following output:

```text
Usage: python -m python_static_types [OPTIONS] [ENV]:[prod|dev|local]

Arguments:
  [ENV]:[prod|dev|local]  [default: local]

Options:
  --verbose / --no-verbose  Enable debug logging  [default: no-verbose]
  --help                    Show this message and exit.
```

And attempting to pass an invalid environment:

```shell
python -m python_static_types nonexistent-env
```

…will display an informative error message and exit with a failure code.

```text
Usage: python -m python_static_types [OPTIONS] [ENV]:[prod|dev|local]
Try 'python -m python_static_types --help' for help.

Error: Invalid value for '[ENV]:[prod|dev|local]': 'nonexistent-env' is not one of 'prod', 'dev', 'local'.
```
