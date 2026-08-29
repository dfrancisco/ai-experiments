# Model Shootout

A small experiment in comparing AI models and exploring how to evaluate their outputs.

## Question

**How do different AI models respond to the same problem, and how can we evaluate those responses?**

The goal wasn't to build a rigorous benchmark. It was to get hands-on experience calling multiple models through a common API, comparing their outputs, and then experimenting with using an LLM to evaluate those outputs.

## Experiment

I gave several models the same prompt:

> I have a year off between jobs and want to use it to become significantly better at building with AI. Give me three unconventional ways to use that time. Optimize for learning and interestingness, not making money.

The experiment records:

- The model actually returned by the API
- Response latency
- The model's answer

Models tested included:

- NVIDIA Nemotron 3 Super 120B A12B
- MiniMax M3
- MiniMax M2.7

## The progression

The experiment started very simply:

**1. Ask multiple models the same question**

Call each model through OpenRouter and print the results side-by-side.

**2. Evaluate the answers ourselves**

Initially, the most obvious way to compare the outputs was simply to read them.

This was useful, but it doesn't scale very well. Once you have many models, prompts, or repeated runs, manually inspecting every answer becomes expensive and subjective.

**3. Use an LLM as a judge**

The next step was to have another model evaluate the outputs.

This introduces a more interesting question:

**Can we use AI to evaluate AI?**

Instead of treating evaluation as something that happens after building the system, evaluation becomes part of the system itself.

## What I learned

- OpenRouter provides a common interface for calling models from different providers.
- Different models can produce substantially different responses to exactly the same prompt.
- Model latency can vary significantly.
- Free model endpoints can be rate-limited or fail, so API calls need error handling.
- Looking at model outputs manually is a useful starting point for understanding differences.
- As the number of outputs grows, automated evaluation becomes increasingly valuable.
- Using an LLM as a judge creates a new problem: **how do you know the judge is judging well?**

That last question is probably more interesting than the original model comparison.

## What surprised me

The models differed not just in the ideas they produced, but in how they approached the problem.

Some responses were more direct and concise, while others spent substantially more effort reasoning before producing an answer.

This made it clear that "which model is best?" is not really a single question.

The answer depends on **what we're evaluating and what we care about**.

## What's next

A more rigorous version of this experiment could:

- Run each prompt multiple times
- Define explicit evaluation criteria
- Compare LLM-judge results against human judgments
- Test whether different judges agree
- Explore whether the judge is biased toward particular models or styles
- Measure the cost and latency of evaluation

For now, the goal is to keep the experiment small and move on to the next thing.

## The bigger lesson

A model call is easy.

The more interesting engineering problem is building a system around the model — including **how you know whether it's actually doing a good job.**

**Build → GitHub → learn → share**

