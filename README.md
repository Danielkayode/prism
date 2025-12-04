# Prism

AI-powered IDE with chat, tool-calls, subscriptions, and Firebase Auth.

## One-time setup
- Add GoogleService-Info.plist to the iOS app target.
- In CodeApp/Info.plist, set:
  - PRISM_BACKEND_URL = https://your-backend.example.com
  - OPENAI_API_KEY, ANTHROPIC_API_KEY, GOOGLE_API_KEY (optional if you inject elsewhere)
  - CFBundleURLTypes -> $(GOOGLE_REVERSED_CLIENT_ID) from your GoogleService-Info.plist
- Deploy backend/functions (Firebase Functions) with env:
  - STRIPE_SECRET_KEY, STRIPE_WEBHOOK_SECRET, STRIPE_PRICE_PRO, STRIPE_PRICE_TEAM
  - SUCCESS_URL, CANCEL_URL

## Run
- Open Code.xcodeproj, select iOS target, Run.
- Sign in with Email/Google/Apple/GitHub.
- Subscribe to Pro via Stripe Checkout.

## Features (Changelog)
- Chat panel with streaming responses and model picker (GPT-5, Claude Sonnet, Gemini 2.5 Pro)
- Unified tool-call event cards and context drawer
- Token usage bar with reset memory
- Tasks/Todo list auto-created from tool events
- Firebase Auth: Email/Password, Google, Apple, GitHub
- Subscriptions: Free (10K tokens), Pro (unlimited); Stripe webhook auto-updates plan
- Free-tier gating and upgrade modal

## Backend
See backend/functions for Stripe webhook and createCheckoutSession function.

Bringing desktop-like editing experience to iPad, available on [App Store](https://apps.apple.com/us/app/code-app/id1512938504) and [TestFlight](https://testflight.apple.com/join/EgZ8sE2P).

![Code App Screenshot](https://thebaselab.com/code/clang.png)

## About the repository

This repository contains the source code of the app. We also work on issues, listen to your feedback and publish our development plan here.

## Documentation

See [code.thebaselab.com](https://code.thebaselab.com)

## The Plan

Use [VS Code](https://github.com/microsoft/vscode) as a design template while providing key functionalities with [monaco-editor](https://github.com/microsoft/monaco-editor) and native code:

- Version Control (Git clone, commits, diff editor, push, pull and gutter indicator) ✅
- Embeded terminal (70+ commands avaliable) ✅
- C/C++ Runtime with WebAssembly (with clang) ✅
- SSH Support ✅
- [LSP](https://microsoft.github.io/language-server-protocol) support (Python, Java & F#) ✅ 

**Note:** Several features listed in previous versions of this README (such as local runtimes for Python, Node, and Java) were mock implementations and have been removed. This is part of an ongoing effort to make the app more stable and production-ready by focusing on core, well-implemented features.

## Building the project

1. `git clone https://github.com/thebaselab/codeapp`
2. `./downloadFrameworks.sh`
3. Open Code.xcodeproj
4. Switch to CodeUI target if you wish to run the app on a simulator
5. Click build

The source code of the built-in languages are hosted on these repositories.
| Language | Repository |
|-----------------|-------------------|
| Python 3.9.2 | [cpython](https://github.com/holzschu/cpython/tree/3.9)|
| Clang 14.0.0 | [llvm-project](https://github.com/holzschu/llvm-project)|
| PHP 8.3.2 | [php-src](https://github.com/bummoblizard/php-src/tree/PHP-8.3.2)|
| PHP 8.3.2 | [php-src](https://github.com/bummoblizard/php-src/tree/PHP-8.3.2)|
| Node.js 18.19.0 | [nodejs-mobile](https://github.com/1Conan/nodejs-mobile)|
| OpenJDK 8 | [android-openjdk-build-multiarch](https://github.com/thebaselab/android-openjdk-build-multiarch)|
| F# (.NET SDK) | [dotnet/fsharp](https://github.com/dotnet/fsharp) |
