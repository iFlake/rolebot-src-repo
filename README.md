# Role bot

This is a bot that allows you to set roles based on TypeRacer scores.

It follows Speed Typers roles conventions:
```
Transcended: 171+ WPM
Ascended: 151-170 WPM
Illuminati: 141-150 WPM
Keyboard Grandmaster: 131-140 WPM
Keyboard Master: 121-130 WPM
Jedi Typist: 111-120 WPM
Elite Typist: 91-110 WPM
Professional: 71-90 WPM
Advanced: 51-70 WPM
Intermediate: 31-50 WPM
Trainee: 0-30 WPM
```

## Setting up

Edit `lib/config.example.dart` and rename it to `lib/config.dart` to set this bot up. It should be pretty self-explanatory.
Then create a file called `data/users.json` and paste the following text into it:
```JSON
[]
```

## Starting

Run `pub run rolebot` to start this bot.
