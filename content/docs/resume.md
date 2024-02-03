---
title: "Curriculum Vitae"
date: 2016-01-29T15:30:00-05:00
draft: false
---

<!-- Include contact info -->

## Education

<div class="box">

### BSc in Software Engineering with Honors

{{< columns >}}
University of Texas at Dallas
<--->
August 2014–May 2018
<--->
Dallas, TX
{{< /columns >}}

- Presented honors capstone on implementation of new mutators in [PIT](http://pitest.org/), a Java virtual machine (JVM) bytecode-based mutation testing framework.
- Named President of campus Linux Users Group (LUG) for 2016–17 and 17–18 academic years.
  Named Secretary for Fall 2016 semester.
- Elected officer in Collegium V Honors College for 2016–17 and 17–18 academic years.

</div>

## Work Experience

<div class="box">

### Renaissance Learning

{{< columns >}}
DevOps Engineer
<--->
March 2021--Present
<--->
Full-Time Remote
{{< /columns >}}

{{< details title="Title History" open=true >}}

- 2022-01: Promoted to Engineer 3
- 2021-03: Hired as Engineer 2

{{< /details >}}

</div>

<div class="box">

### J. C. Penney

{{< columns >}}
DevOps Engineer
<--->
June 2018--February 2021
<--->
Plano, TX
{{< /columns >}}

{{< details title="Title History" open=true >}}

- 2020-01: Promoted to Engineer 1
- 2018-08: Promoted to Junior Engineer
- 2018-06: Hired as Engineering Intern

{{< /details >}}

- Led development of department's Python RESTful service framework to create first-class experience for Python machine learning developers in a Spring Boot-centric ecosystem.
  The company's first customer-serving Python services were written on top of the framework.
  - Designed and implemented configuration layering system to integrate data from Spring Cloud, environment variables exposed by Docker Compose, command-line options, and YAML files.
  - Adopted existing open source libraries to perform service registration with Eureka, then incrementally rewrote the library's threading and payload serialization on an internal fork to fix stability issues.
- Brought DevOps team's outstanding ticket count from above 300 to fewer than 20 as interim Scrum Master from October 2019--March 2020.
- Led Python 2 to 3 migration effort for department's existing Python codebases.
  - Added type checking over the course of the refactoring using [stdlib typing](https://docs.python.org/3/library/typing.html), [pydantic](https://pydantic-docs.helpmanual.io/), and [mypy](https://www.mypy-lang.org/).
  - Enforced successful per-repository type checking and formatting via continuous integration (CI) jobs.
- Authored the department's internal Python setup guide, covering steps from virtual environment creation through configuration of pre-commit hooks.
- Responsible for adding test suites to new and existing Python codebases.
  This work led to the first property-based testing at the organization, implemented via [Hypothesis](https://pypi.org/project/hypothesis/) on top of [pytest](https://pypi.org/project/pytest/).
- Built internal REST service to automate creation of new project repositories.
  - Wrote backend RESTful service in Python 3 using [Flask](https://pypi.org/project/Flask/), [Requests](https://pypi.org/project/requests/), and [GitPython](https://pypi.org/project/GitPython/).
  - Wrote frontend as a SPA in Angular 4 for integration into an existing dashboard.
- Maintained Python/Hy helper scripts to automate teams' operational activities such as SSL certificate rolling and bulk deployment of application microservices.
- Helped application teams create and troubleshoot Jenkins pipelines, Gradle builds, and Docker Swarm container deployments.
- Automated migration of department's chat groups from Atlassian Hipchat to Microsoft Teams.

</div>

<div class="box">

### Northrop Grumman

{{< columns >}}
Engineering Intern
<--->
Summer 2016
<--->
Oklahoma City, OK
{{< /columns >}}

- Collaborated with other interns to design and execute experiment to test Distributed Data Service (DDS) middleware.
- Tasked with measuring the impact various quality of service (QoS) policies had on the performance of DDS.
- Templated C++ source code with Python in order to generate DDS entities at production scale.
- Automated the capture of DDS's network traffic during specific lifecycle phase with Wireshark.
- Oversaw setup and maintenance of software on isolated test network.
- Explored policies for publishing generic configurations in a security-conscious environment.
- Guided teammates in version control best practices.

</div>

<div class="box">

### Lenoir City Utilities Board

{{< columns >}}
IT Intern
<--->
Summers 2013–15
<--->
Lenoir City, TN
{{< /columns >}}

- Developed prototype Android app to streamline customer service requests.
  - Independently performed mockup, implementation, and testing.
- Resolved help desk calls for approximately 75 employees across two buildings.
- Wrote and published [Symantec Endpoint uninstaller](https://github.com/lafrenierejm/Symantec_Endpoint_Uninstall_Script), a script to cleanup failed Symantec Endpoint installations sufficiently to allow for successful reinstallation.

</div>

## Open Source

{{< hint warning >}}
The contributions listed here are _not_ exhaustive.
See my GitHub profile, <a href="https://github.com/lafrenierejm/"><code>&#64;lafrenierejm</code></a>, for a more comprehensive list of recent contributions.
{{< /hint >}}

<div class="box" style="/*! outline-width: 0.1em; */border: 1px solid var(--gray-200);border-radius: .25rem;padding-left: 1em;margin-bottom: 1ex">

### ripgrep-all

{{< columns >}}
Contributor
<--->
2022-12--Present
<--->
[Authored pull requests](https://github.com/phiresky/ripgrep-all/pulls?q=is%3Apr+author%3Alafrenierejm)
{{< /columns >}}

ripgrep-all is a CLI application that extracts textual information from non-text files (e.g. PDF, sqlite), caches the resulting text, and transparently runs [ripgrep](https://github.com/BurntSushi/ripgrep) on the text for performant searching.

- Implemented `async` support in the Rust codebase for the [pagebreak algorithm](https://github.com/phiresky/ripgrep-all/pull/150).
- Introduced Nix flake with [Rust library caching](https://github.com/phiresky/ripgrep-all/pull/148) and [propagated runtime dependencies](https://github.com/phiresky/ripgrep-all/pull/187).
- [Updated CI workflow](https://github.com/phiresky/ripgrep-all/pull/164) to use Nix for reproducibility, resolving spurious failures that were caused by upstream changes in the CI runner.

</div>

<div class="box" style="/*! outline-width: 0.1em; */border: 1px solid var(--gray-200);border-radius: .25rem;padding-left: 1em;margin-bottom: 2ex">

### ripsecrets

{{< columns >}}
Contributor
<--->
2022-04--Present
<--->
[Authored Pull Requests](https://github.com/sirwart/ripsecrets/pulls?q=is%3Apr+author%3Alafrenierejm)
{{< /columns >}}

- [Introduced Nix flake](https://github.com/sirwart/ripsecrets/pull/9) with Rust library caching.
- Added [GitHub Actions workflow](https://github.com/phiresky/ripgrep-all/tree/master/.github/workflows/ci.yml) to check for successful build and consistent formatting in CI.
- Defined Docker image in Nix flake and [GitHub Actions workflow](https://github.com/sirwart/ripsecrets/pull/46) to publish to Docker Hub on tag.

</div>

<div class="box">

### standard-dirs.el

{{< columns >}}
Author and maintainer
<--->
2018-03--Present
<--->
[Source code](https://github.com/lafrenierejm/standard-dirs.el)
{{< /columns >}}

_Standard Dirs_ is an Emacs library to provide platform-specific paths for reading and writing configuration, cache, and other data.

- On Linux, the directory paths conform to the XDG base directory and XDG user directory specifications as published by the freedesktop.org project.
- On macOS, the directory paths conform to Apple’s filesystem documentation ["Where to Put Files"](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFileSystem/Articles/WhereToPutFiles.html).

</div>

<div class="box">

### emacs-ghq

{{< columns >}}
Maintainer
<--->
2023-05--Present
<--->
[Source code](https://github.com/lafrenierejm/emacs-ghq)
{{< /columns >}}

_Emacs ghq_ is an Emacs utility for leveraging [ghq](https://github.com/x-motemen/ghq) to manage local repositories.

</div>

<div class="box">

### ietf-cli

{{< columns >}}
Author
<--->
2016-11--2017-01
<--->
[Source code](https://github.com/lafrenierejm/ietf-cli)
{{< /columns >}}

Wrote an alternative to the [command-line program espoused on ietf.org's wiki](https://trac.tools.ietf.org/tools/ietf-cli/), motivated by a desire for a better querying features and a cleaner codebase.
My goals for the rewrite were to use then-idiomatic Python 3 and provide easy querying.
I decided on a database backend (as opposed to the original tool's single XML file) to allow querying documents by title, author, keyword, or authoring organization.
SQLite was chosen for the database implementation due to the single-user nature of the project and the prioritization of ease-of-installation.

- Wrote a scraper to generate queryable metadata from the XML file that the IETF published as its document index.
- Used object-relational mapping capabilities of SQLAlchemy to interact with the SQLite3 backend.
- Made use of the database backend to implement automatic retrieval of documents that update or obsolete a given document.
- Implemented subcommand-style CLI frontend using `argparse`.
- Depended on `rsync` as an external program to fetch latest versions of the upstream IETF publications.

</div>

<div class="box">

### format-flowed.vim

{{< columns >}}
Author
<--->
2016-11--2017-01
<--->
[Source code](https://gitlab.com/lafrenierejm/vim-format-flowed)
{{< /columns >}}

Wrote a Vim plugin enabling full support of [RFC 3676 _The Text/Plain Format and DelSp Parameters_](https://tools.ietf.org/html/rfc3676) in Vim's `mail` filetype.
The plugin dynamically sets `formatoptions` and `tab` settings based on the location of the cursor in a buffer.

The project started as a refactor of an existing script found in the Vim user Google Group, but after several iterations ended up sharing none of the original code.

- Rewrote the regular expressions used to detect headers, signatures, patch snippets, and quotations.
- Expanded the `set` options to account for…
  - automatic reformatting,
  - auto-wrapping paragraphs,
  - the effects of trailing whitespace, and
  - the behavior of tab characters.
- Packaged the script for use with modern (at the time) Vim plugin managers.

</div>
