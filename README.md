# Pomodoro
A simple Pomodoro app that notifies you at the end of each interval.

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
