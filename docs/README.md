---
title: "Overview"
weight: 1
---

# Overview

The SparkleFormation CLI (`sfn`) is a Ruby based command line interface
for interacting with remote orchestration API. It is an application
implementation of the SparkleFormation library and provides access to
all the underlying features provided by the SparkleFormation library.

## Table of Contents

- [Feature Summary](#feature-summary)
- [Configuration](configuration)
  - [sfn based](configuration#sfn-based)
  - [knife based](configuration#knife-based)
- [Usage](usage)
  - [Commands](usage#commands)
- [Callbacks](callbacks)
  - [Enabling Callbacks](callbacks#enabling-callbacks)
  - [Builtin Callbacks](callbacks#builtin-callbacks)
  - [Custom Callbacks](callbacks#custom-callbacks)

## Feature Summary

Notable features available via the SparkleFormation CLI:

- SparkleFormation template processing
- Template processing helpers
- Custom callback support
- Remote orchestration API support
  - AWS CloudFormation
  - Eucalyptus
  - Rackspace Orchestration
  - OpenStack Heat
- Chef `knife` plugin support
- Deep resource inspection
