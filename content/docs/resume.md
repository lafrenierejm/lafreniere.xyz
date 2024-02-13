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
Richardson, TX
{{< /columns >}}

<span class="date" id="utd-start">2014-08-01</span>–<span class="date" id="utd-end">2018-05-31</span>
<span class="tenure" id="utd-tenure"></span>

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
Full-Time Remote
{{< /columns >}}

<span class="date" id="ren-start">2021-03-01</span>--<span class="date" id="ren-end">Present</span>
<span class="tenure" id="ren-tenure"></span>

{{< details title="Title History" open=true >}}

- <span class="date">2021-03</span>: Hired as Engineer 2
- <span class="date">2022-02</span>: Promoted to Engineer 3
- <span class="date">2024-02-05</span>: Promoted to Senior Engineer

{{< /details >}}

- Leading the department's migration from a self-hosted GitHub Enterprise (GHE) Server instance to GHE Cloud.
- Completed the migration of Subversion (SVN) repositories to Git and shutdown the SVN server.
  - The migration from SVN to Git had been started about 6 years prior, but was never fully completed due to the size of several of the repositories (largest had 198k commits and was 80GiB on disk).
  - Used a combination of [`svndumpsanitizer`](https://github.com/dsuni/svndumpsanitizer) and the [BFG](https://rtyley.github.io/bfg-repo-cleaner/) to split up SVN monorepos into multiple Git repositories.
- Led the department's migration from a self-hosted JFrog Artifactory instance to AWS CodeArtifact.
  - All existing data from Artifactory was retained.
  - To minimize disruption to development teams, we implemented dual-publishing in the central build library during the transition phase.
- Led the team's upgrade of multiple Jenkins instances from 1.2 to 2.361.4 (latest LTS release at time of upgrade).
  - Downtime was approximately 15 minutes per instance.
  - All data was retained, including build history and console logs.
- Contributed significantly to both the design and implementation of a continuous delivery (CD) system for the department's customer-facing SAAS products.
  - Played a key role in adding support for deploying [AWS Lambda](https://aws.amazon.com/lambda/) functions and [CloudFront](https://aws.amazon.com/cloudfront/)-backed content.
  - Made the case for and successfully implemented a refactor from [Flask 1](https://flask.palletsprojects.com/en/1.1.x/) to [FastAPI](https://fastapi.tiangolo.com/).
    This had several key benefits:
    1. Reduced the number of bugs discovered in the service's production environment due to strict schema enforcement on both requests and responses.
    1. Increased velocity due to better static type checking.
    1. Improved baseline performance versus Flask and opened up even more performance improvements via support for `async`.
  - Measurably improved the performance of key endpoints by selectively replacing uses of synchronous IO libraries (namely [Requests](https://requests.readthedocs.io/en/latest/) and [botocore](https://botocore.amazonaws.com/v1/documentation/api/latest/index.html)) with asynchronous libraries ([HTTPX](https://www.python-httpx.org/) and [aiobotocore](https://github.com/aio-libs/aiobotocore), respectively).

</div>

<div class="box">

### J. C. Penney

{{< columns >}}
DevOps Engineer
<--->
Plano, TX
{{< /columns >}}

<span class="date" id="jcp-start">2018-06</span>--<span class="date" id="jcp-end">2021-02</span>
<span class="tenure" id="jcp-tenure"></span>

{{< details title="Title History" open=true >}}

- <span class="date">2018-06</span>: Hired as Engineering Intern
- <span class="date">2018-08</span>: Promoted to Junior Engineer
- <span class="date">2020-01</span>: Promoted to Engineer 1

{{< /details >}}

- Led the development of department's Python RESTful service framework to create a first-class experience for Python machine learning developers in a Spring Boot-centric ecosystem.
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
- Automated the migration of department's chat groups from Atlassian Hipchat to Microsoft Teams.

</div>

<div class="box">

### Northrop Grumman

{{< columns >}}
Engineering Intern
<--->
Oklahoma City, OK
{{< /columns >}}

<span class="date" id="ng-start">2016-05</span>--<span class="date" id="ng-end">2016-08</span>
<span class="tenure" id="ng-tenure"></span>

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
Lenoir City, TN
{{< /columns >}}

Summers 2013, 14, 15 (8 months)

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
[Authored pull requests](https://github.com/phiresky/ripgrep-all/pulls?q=is%3Apr+author%3Alafrenierejm)
{{< /columns >}}

<span class="date" id="rga-start">2022-12-01</span>--<span class="date" id="rga-end">Present</span>
<span class="tenure" id="rga-tenure"></span>

Command-line interface (CLI) application written in Rust that extracts textual information from non-text files (e.g. PDF, sqlite), caches the resulting text, and transparently runs [ripgrep](https://github.com/BurntSushi/ripgrep) on the text for high-performance searching.

- Implemented `async` support in the Rust codebase for the [pagebreak algorithm](https://github.com/phiresky/ripgrep-all/pull/150).
- Introduced Nix flake with [Rust library caching](https://github.com/phiresky/ripgrep-all/pull/148) and [propagated runtime dependencies](https://github.com/phiresky/ripgrep-all/pull/187) for efficient, reproducible builds.
- [Updated CI workflow](https://github.com/phiresky/ripgrep-all/pull/164) to use Nix for reproducibility, resolving spurious failures that were caused by upstream changes in the CI runner.

</div>

<div class="box">

### ripsecrets

{{< columns >}}
Contributor
<--->
[Authored Pull Requests](https://github.com/sirwart/ripsecrets/pulls?q=is%3Apr+author%3Alafrenierejm)
{{< /columns >}}

<span class="date" id="ripsecrets-start">2022-04-01</span>--<span class="date" id="ripsecrets-end">Present</span>
<span class="tenure" id="ripsecrets-tenure"></span>

CLI application written in Rust that scans a codebase for cleartext secrets.

- [Introduced Nix flake](https://github.com/sirwart/ripsecrets/pull/9) with Rust library caching for efficient, reproducible builds.
- Added [GitHub Actions workflow](https://github.com/phiresky/ripgrep-all/tree/master/.github/workflows/ci.yml) to check for successful build and consistent formatting in CI.
- Defined Docker image in Nix flake and [GitHub Actions workflow](https://github.com/sirwart/ripsecrets/pull/46) to publish to Docker Hub on tag.

</div>

<div class="box">

### standard-dirs.el

{{< columns >}}
Author and maintainer
<--->
[Source code](https://github.com/lafrenierejm/standard-dirs.el)
{{< /columns >}}

<span class="date" id="stddirs-start">2018-03-01</span>--<span class="date" id="stddirs-end">Present</span>
<span class="tenure" id="stddirs-tenure"></span>

Emacs library to provide platform-specific paths for reading and writing configuration, cache, and other data.

- On Linux, the directory paths conform to the [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).
- On macOS, the directory paths conform to Apple’s filesystem documentation ["Where to Put Files"](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFileSystem/Articles/WhereToPutFiles.html).

</div>

<div class="box">

### emacs-ghq

{{< columns >}}
Maintainer
<--->
[Source code](https://github.com/lafrenierejm/emacs-ghq)
{{< /columns >}}

<span class="date" id="ghq-start">2023-05-01</span>--<span class="date" id="ghq-end">Present</span>
<span class="tenure" id="ghq-tenure"></span>

Emacs utility for leveraging [ghq](https://github.com/x-motemen/ghq) to manage local repositories.

</div>

<div class="box">

### ietf-cli

{{< columns >}}
Author
<--->
[Source code](https://github.com/lafrenierejm/ietf-cli)
{{< /columns >}}

<span class="date" id="ietf-start">2017-06-01</span>--<span class="date" id="ietf-end">2017-07-31</span>
<span class="tenure" id="ietf-tenure"></span>

Alternative to the [command-line program espoused on ietf.org's wiki](https://trac.tools.ietf.org/tools/ietf-cli/), motivated by a desire for better querying features and a cleaner codebase.
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
[Source code](https://gitlab.com/lafrenierejm/vim-format-flowed)
{{< /columns >}}

<span class="date" id="fflowed-start">2016-11-01</span>--<span class="date" id="fflowed-end">2017-01-31</span>
<span class="tenure" id="fflowed-tenure"></span>

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
