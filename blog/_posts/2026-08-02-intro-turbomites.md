---
layout: post
title: "Welcome To Turbomites"
date: 2026-08-02
---

# Introduction

**Turbomites** is a Delphi implementation of Turmites with a few new tricks.


## Core Architecture

Turbomites is implemented as a "headless" simulator that runs in a thread, and a rendering engine that displays to a `TSkAnimatedPaintBox` in the main thread. This separation allows for running the simulator at Ludicrous Speed, while still maintaining a high FPS.


## Antabilities

The primary things I wanted to experiment with in regards to ant behavior were:

  - **Both Relative and Absolute Turns** Ants face a direction, so you can turn them either relative with left, right, about-face and continue, or turn them to an absolute cardinal direction.

  - **Multiple Ants** If you include multiple ants they'll share the same space, and therefore find each other's colors and can react accordingly.


## Scenario Files

JSON files that live in the `bin` directory are automatically scanned and presented in the UI. Each file represents a "scenario" which includes the ants' rules/states, the number/definition for ants, and instructions on what to pre-populate in the grid, if desired.

The program will watch the bin folder for JSON file changes, so you can just edit and save the scenario file and the simulator will automatically load your changes and restart the simulation (if enabled).


## Syntax Overview

-= coming soon =-


## Development Notes and AI Involvement

-= coming soon =-




