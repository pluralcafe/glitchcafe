![Mastodon](https://i.imgur.com/NhZc40l.png)
========

![Build Status](https://img.shields.io/docker/cloud/build/pluralcafe/mastodon) ![Site Status](https://img.shields.io/website?label=plural.cafe&logo=mastodon&url=https%3A%2F%2Fplural.cafe)

Mastodon is a **free, open-source social network server** based on **open web protocols** like ActivityPub and OStatus. The social focus of the project is a viable decentralized alternative to commercial social media silos that returns the control of the content distribution channels to the people. The technical focus of the project is a good user interface, a clean REST API for 3rd party apps and robust anti-abuse tools.

**Ruby on Rails** is used for the back-end, while **React.js** and Redux are used for the dynamic front-end. A static front-end for public resources (profiles and statuses) is also provided.

This repository specifically is for [Plural Café](https://plural.cafe) and has three branches:

* **main** (**edge** on Docker Hub) for all development and staging work,
* **glitch** for all commits from upstream that will automatically be synched to this repository, and
* **production** (**latest** on Docker Hub) for what goes onto the main website.

In addition, there are several repositories in this GitHub organization:

* **pluralcafe/mastodon** is this repository and is the codebase for what Plural Café runs,
* [**pluralcafe/utils**](https://github.com/pluralcafe/utils) are an assortment of scripts and tutorials to help in Mastodon system administration or general helper files this instance uses,
* [**pluralcafe/barkeep**](https://github.com/pluralcafe/barkeep) is forked from [mbilokonsky/ambassador](https://github.com/mbilokonsky/ambassador) and serves as the Ambassador bot that is run on the instance.

This instance is a fork of a fork: this has the [Mastodon Glitch Edition](https://github.com/glitch-soc/mastodon) commits. Documentation for Mastodon Glitch Edition [can be found here](https://glitch-soc.github.io/docs/). Anyone wishing to use Glitch Edition in a Docker image for their own site can use the `pluralcafe/mastodon:glitch` image.

---

## Changes from Upstream

* 2126fd0cd tweak to ordered list display
* 3de0fecfa support summary/details HTML
* cb7608c37 allow gemini protocol links