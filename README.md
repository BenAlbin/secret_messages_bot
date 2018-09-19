# SecretMessagesBot

Discord bot that allows you to play certain 'pen and paper' games within a discord guild (server). The features are incredibly simple to allow users to play many different games, but note-taking and scores still will need to be done manually.

Note: I have deliberately not allowed this bot to be installed on your own server, while I iron out the bugs and write tests.

### Commands

Command | Usage
------- | -----
!!setup | Begins a game, this command must be used before users can join.
!!join | Joins a game that has been initialised. After using this command, a private channel will be created for you that others cannot see.
!!ready | Used in your private channel to signal that you have typed your messages for the current round. The round will end when all players are ready.
!!finish | Cleans up all the channels/roles when a game has ended. Currently this must be used manually.

### Planned Changes

- [ ] Refactor cleaning up into it's own module, so it's easier to trigger a clean-up when a game times out.
- [ ] Clean up the GenServer code and create an implementation behaviour to allow for more reasonable testing.
- [ ] Fix a bug where if a player types more than the field limit for a discord card in a round, the messages from that round is lost.
- [ ] Change Supervisor to DynamicSupervisor
- [ ] Potentially use a cache within the application for channels and users, so I can deal with the bad practice of using internal Alchemy code within my GenServer implementation. (Or do more work on my Alchemy fork).
- [ ] Have a look at whether GenStageMachine is a more appropriate abstraction for the game state. (Maybe overkill, but it also solves important problems if I want to prevent players joining a game in progress for example, without reinventing the wheel.)

