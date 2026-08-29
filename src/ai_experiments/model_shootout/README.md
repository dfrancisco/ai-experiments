# Model Shootout

A small experiment comparing several AI models on the same task.

## Question

**How differently do current AI models respond to the same problem?**

The goal wasn't to determine which model is "best." It was to get hands-on experience calling multiple models through a common API and see what differences emerge.

## Experiment

I gave each model the same prompt:

> I have a year off between jobs and want to use it to become significantly better at building with AI. Give me three unconventional ways to use that time. Optimize for learning and interestingness, not making money.

Models tested:

- NVIDIA Nemotron 3 Super 120B A12B
- MiniMax M3
- MiniMax M2.7

The experiment records:

- The model actually returned by the API
- Response latency
- The model's answer



## What I learned

- OpenRouter provides a common interface for calling models from different providers.
- Different models can produce substantially different answers to exactly the same prompt.
- Some models expose reasoning content while others return only the final answer.
- Model latency can vary significantly.
- Free model endpoints can be rate-limited or fail, so production code needs to handle API errors gracefully.
- A simple experiment like this is enough to start developing intuition for differences between models.



## What surprised me

The biggest difference wasn't necessarily the quality of the ideas. The models had noticeably different **styles of reasoning and answering**.

Nemotron, for example, spent a substantial amount of its response on explicit reasoning before producing its answer, while MiniMax M3 went much more directly to the recommendations.

That raises a more interesting question for future experiments:

**Can we develop a useful way to evaluate models beyond simply asking which answer "looks better"?**

## What I'd do differently

This experiment is intentionally simple. A more rigorous comparison would:

- Run the same prompt multiple times
- Test more models
- Measure latency systematically
- Use structured evaluation criteria
- Potentially use another model as an evaluator

For now, that's deliberately out of scope. The point was to learn the basic mechanics and establish a foundation for more interesting experiments.

## Next

Move on to the next experiment rather than over-engineering this one.

**Build → GitHub → learn → share**