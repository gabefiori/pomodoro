# Pomodoro
A simple Pomodoro app that notifies you at the end of each interval.

![image](https://github.com/user-attachments/assets/d96563c8-b60b-46af-8cdf-e56fe4b7c981)

## Configuration
You can create a configuration file to override the default durations.
The file is located at `$HOME/.config/pomodoro/config`.

```sh
focus = 20
short-break = 3
long-break = 10
```

## Building
To build the app, ensure you have the [zig compiler](https://ziglang.org/) installed. In your terminal, run:
```sh
zig build -Doptimize=ReleaseFast
```
