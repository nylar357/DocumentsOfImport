
Why you should use `python -m pip`
Nov 1, 2019 6 min read packagingPython

Fellow core developer and Canadian, Mariatta, asked on Twitter about`python -m pip` and who told her about that idiom along with asking for a reference explaining it:

Now I'm not sure if it was specifically me that told Mariatta about `python -m pip`, but the chances are reasonable that it was me as I have been asking for it to become the instructions provided on PyPI on how to install a package since 2016. So this blog post is meant to explain what python -m pip is and why you should be using it when you run pip.
What is `python -m pip`?

To begin with, `python -m pip` executes pip using the Python interpreter you specified as python. So `/usr/bin/python3.7 -m pip` means you are executing pip for your interpreter located at `/usr/bin/python3.7`. You can read the docs on -m if you're unfamiliar with the flag and how it works (it's very handy).
Why use `python -m pip over pip/pip3`?

So you might be saying, "OK, but can't I just run pip by executing the pip command?" And the answer is "yes, but with a lot less control", and I will explain what I mean by "less control" with an example.

Let's say I have two versions of Python installed, like Python 3.7 and 3.8 (and this is very common for people thanks to Python coming installed on macOS and Linux, let alone you may have installed Python 3.8 to play with it while having previously installed Python 3.7). Now, if you were to type pip in your terminal, which Python interpreter would it install for?

Without more details the answer is you don't know. First you would have to know what my `PATH` is set to, e.g. is /usr/bin before or after `/usr/local/bin` (which are common locations for Python to be installed into, and typically` /usr/local/` comes first). OK, so as long as you remember where you installed Python 3.7 and 3.8 and that it was different directories you will know which version of pip comes first on `PATH`. But let's say you installed both manually; maybe your OS came with Python 3.7.3 and you installed Python 3.7.5. In that case both versions of  Python are installed in `/usr/local/bin`. Can you now tell me what interpreter pip is tied to?

The answer is you still don't know. Unless you know when you installed each version and thus what the last copy of pip was written to `/usr/local/bin/pip` you don't know what interpreter pip will be using for the pip command. Now you may be saying, "I always install the latest versions, so that would mean Python 3.8.0 was installed last since it's newer than 3.7.5". OK, but what happens when Python 3.7.6 comes out? Your pip command would have gone from using Python 3.8 to Python 3.7.

But when you use `python -m pip` with python being the specific interpreter you want to use, all of the above ambiguity is gone. If I say `python3.8 -m pip` then I know pip will be using and installing for my Python 3.8 interpreter (same goes for if I had said python3.7).

And if you're on Windows there is an added benefit to using python -m pip as it lets pip update itself. Basically because pip.exe is considered running when you do `pip install --upgrade pip`, Windows won't let you overwrite pip.exe. But if you do `python -m pip install --upgrade pip` you avoid that issue as it's python.exe that's running, not pip.exe.
What about when I am in an activated environment?

Usually when I explain this to a group of people inevitably someone will say "I always use a virtual environment and so this doesn't apply to me". So first, great job on always using an environment (I will argue why this is a best practice later on this blog post)! But I would honestly still argue for using python -m pip even when it strictly isn't necessary.

First, if you're on Windows you will want to still use python -m pip just so you can update pip in your environment.

Second, even if you're on another OS I would say you should use python -m pip as it works regardless of the situation. Not only does it prevent you from making a mistake if you happen to forget to active your environment, but it also means anyone watching you will learn the best practice as well. And personally I don't think saving 10 keystrokes for a command you are probably not executing constantly warrants taking a shortcut from a universal best practice. It also prevents you from accidentally scripting some automation that will do the wrong thing if you forget to activate your environment.

Personally, any tool that I use whose execution relies on which interpreter it is run with I always use -m, activated environment or not, in order to be very purposefully and explicit in what Python interpreter I want to be used/affected.
ALWAYS use an environment! Don't install into your global interpreter!

While we're on the subject of how to avoid messing up your Python installation, I want to make the point that you should never install stuff into your global Python interpreter when you develop locally (containers are a different matter)! If it's your system install of Python then you may actually break your system if you install an incompatible version of a library that your OS relies on.

But even if you install your own copy of Python I still strongly advise against installing directly into it when developing locally. You will end up mixing various packages between your projects which could clash with each other, you won't have a clear idea of what each of your projects truly depends on, etc. It is much better to use environments to isolate your individual projects and tools from each other. And in the Python community there are two types of environments: virtual environments and conda environments. There's even a way to install Python tools in an isolated fashion.
If you need to install a tool

For installing a tool in isolation, I would  use pipx. Each tool will get their own virtual environment so they won't clash with each other. That way if you want to have a single installation of e.g. Black you can do so without accidentally breaking your single installation of mypy.
If you need an environment for your project (and you don't use conda)

When you need to create an environment for a project I personally always reach for venv and virtual environments. It's included in Python's stdlib so it's always available via `python -m venv` (as long as you are not on Debian/Ubuntu, otherwise you may have to install the `python3-venv apt package`). A bit of history: I actually removed the old pyvenv command that Python used to install for creating virtual environments with venv for the exact reasons why you should use `python -m pip` over `pip`; from the command alone you can't know which interpreter you were creating a virtual environment for via the old pyvenv command. And remember you don't have to activate the environment to use the interpreter contained within it; `.venv/bin/python` works just as well as activating the environment and typing python.

Now some people still prefer virtualenv as it's available on Python 2 and has some other extra features. Personally, I don't need the extra features and having venv integrated means I don't have to use pipx to install virtualenv on every machine. But if venv doesn't meet your needs and you want a virtual environment then see if virtualenv does what you need.
If you are a conda user

If you are a conda user, then you can use conda environments for the same effect as virtual environments as provided by venv. I'm not going to go into whether you should use conda for your situation over venv, but if you find yourself using conda then do know you can (and should) create conda environments for your work instead of installing everything into your base environment and having a clear understanding of what your project depends on (and this is also a good reason to use miniconda over anaconda as the former is less than a tenth of the install size of the latter).
There's always containers

Working in a container is another option as you can skip environments at that point since the whole "machine" is the environment. As long as you are not installing into the system Python of the container you should be free to do a global install to keep your container simple and straight-forward.
To repeat myself to really try to get the point across ...

DO NOT install into your global Python interpreter! ALWAYS try to use an environment when developing locally!

I cannot count the number of times I had to help someone who thought pip was installing into one Python interpreter and in fact it was the other. And that immeasurable count also applies to when people have broken their system or wondered why they couldn't install something that conflicted with some other thing they installed previously for some other project, etc. due to not bothering to set up an environment on their local machine.

So for your sanity and mine, use `python -m pip` and always try to use an environment.
