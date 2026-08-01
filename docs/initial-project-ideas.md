
## Turbomites 

- both relative and absolute turn instructions
- multiple states
- multiple colors
- multiple ants


### Order Of Operations

1. read color under feet
2. select rule by color
3. write rule color
4. turn rule direction
5. move
6. change state to rule's next state

### Rules and Defaults

- `find` specifies which color this rule applies to. If not provided, this rule is the default for all colors.
- `write` specifies what color to write into the cell. Required.
- `turn` specifies either a relative or absolute direction. If not provided, default is no turn.
- `state` specifies the state to change to after all other steps have been executed. Optional.
- only one rule within a state may omit the "find" node

- turn commands
  - L = left
  - R = right
  - A = around
  - N = north
  - S = south
  - E = east
  - W = west


### State Example

When the ant is in "start" state:

  - if ant is on 0, change it to 2, turn relative right and move, change to state "one"
  - if ant is on 2, change it to 1, turn relative left and move, remain in "start"
  - if ant is on 1, change it to 0, turn around and move, remain in "start"
  - if ant finds a color other than 0, 1, 2, change it to 0, turn absolute South and move, remain in "start"

```json
{
  "start": [
    {"find": 0, "write": 2, "turn": "R", "state": "one"},
    {"find": 2, "write": 1, "turn": "L"},
    {"find": 1, "write": 0, "turn": "A"},
    {"write": 0, "turn": "S"},
  ],
  "one": [
    {"find": 0, "write": 1, "turn": "R"},
    {"find": 1, "write": 0, "turn": "L"},
    {"find": 2, "write": 0, "turn": "N", "state": "start"}
  ]
}

```


Turmites according to Wikipedia:

```
As with Langton's ant, turmites perform the following operations each timestep:

1. turn on the spot (by some multiple of 90°)
2. change the color of the square
3. move forward one square.
```
