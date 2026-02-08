# 🔍 Bypass Research Documentation

> **SafeGuard AI - Bypass Detection Patterns**
> 
> Made with ❤️ for the Roblox community by **@Higanste**

This document lists the bypass patterns that SafeGuard AI is trained to detect. The AI uses these patterns as context to understand malicious intent behind creative spelling.

---

## 1. Off-Platform Contact Bypasses

Players often try to move conversations off Roblox to avoid moderation. These are **high priority** because they're often associated with grooming.

### Discord
| Bypass | Meaning |
|--------|---------|
| dizzy | Discord |
| disc | Discord |
| dyscord | Discord |
| d!sc0rd | Discord |
| dis cord | Discord |
| dc | Discord |
| discor | Discord |
| add my disc | Add me on Discord |

### Snapchat
| Bypass | Meaning |
|--------|---------|
| snap | Snapchat |
| sc | Snapchat |
| snp | Snapchat |
| snapch@t | Snapchat |
| add my snap | Add me on Snapchat |

### Instagram
| Bypass | Meaning |
|--------|---------|
| insta | Instagram |
| ig | Instagram |
| !nstagram | Instagram |
| insta gram | Instagram |

### TikTok
| Bypass | Meaning |
|--------|---------|
| tt | TikTok |
| t!kt0k | TikTok |
| tik tok | TikTok |

### Other
| Bypass | Meaning |
|--------|---------|
| wa | WhatsApp |
| wh@tsapp | WhatsApp |
| kik | Kik Messenger |
| tel / tele | Telegram |

---

## 2. Leetspeak Substitutions

Common letter-to-symbol/number substitutions:

| Letter | Common Substitutes |
|--------|-------------------|
| a | @, 4, ^ |
| b | 8, 6 |
| c | (, < |
| e | 3, € |
| g | 9, 6 |
| h | # |
| i | 1, !, \|, l |
| l | 1, \|, I |
| o | 0, () |
| s | $, 5, z |
| t | 7, + |
| x | *, >< |

### Examples
- "n!ce" = nice
- "h3llo" = hello
- "wh@t" = what

---

## 3. Spacing & Symbol Tricks

Players insert characters between letters to avoid detection:

### Dot Separation
- `f.u.c.k`
- `n.i.g.g.a`
- `b.i.t.c.h`

### Space Separation
- `f u c k`
- `s h i t`
- `a s s`

### Underscore Separation
- `f_u_c_k`
- `d_i_c_k`

### Mixed Separators
- `f.u c_k`
- `n!.g.g@`

---

## 4. Phonetic Bypasses

Words spelled to sound the same:

| Bypass | Actual Word |
|--------|-------------|
| fawk | fuck |
| phuck | fuck |
| fuk | fuck |
| shyt | shit |
| shiit | shit |
| azz | ass |
| asz | ass |
| bytch | bitch |
| beech | bitch |
| hore | whore |

---

## 5. Slur Bypasses (Zero Tolerance)

> ⚠️ **Warning**: This section contains offensive terms for documentation purposes.

The AI is trained to detect ALL variations of racial and ethnic slurs, including:

### N-Word Variations
- Letter substitutions: n!gga, n1gg3r, niqqer
- Symbol insertion: n.i.g.g.a, n-word
- Partial words: nig, nigg
- Phonetic: knee-gur

### Other Slurs
- All variations using leetspeak
- Regional slurs
- Coded language

---

## 6. Grooming Behavior Patterns

These patterns trigger **IMMEDIATE PERMANENT BANS**:

### Age Probing
- "how old are you"
- "what's your age"
- "asl" / "a/s/l" (age/sex/location)
- "are you 12/13/14..."
- "r u a minor"

### Location Probing
- "where do you live"
- "what city are you in"
- "what school do you go to"
- "are you home alone"
- "when do your parents get home"

### Contact Requests
- "add me on [platform]"
- "dm me"
- "message me privately"
- "give me your [platform]"
- "let's talk somewhere else"

### Photo/Video Requests
- "send pic"
- "show yourself"
- "what do you look like"
- "can I see you"
- "turn on your camera"

### Meeting Requests
- "want to meet up"
- "let's hang out irl"
- "I live near you"
- "can we meet"

### Grooming Tactics
- "don't tell your parents"
- "this is our secret"
- "you're mature for your age"
- "I'll give you robux if..."
- "want free stuff"
- Excessive compliments + contact requests

### Warning Signs Combination
The AI looks for **combinations** that indicate grooming:
- Age question + contact request
- Compliment + platform request
- Gift offer + private conversation

---

## 7. General Toxicity

### Death Threats
- "kys" (kill yourself)
- "go die"
- "I'll kill you"
- Variations with leetspeak

### Harassment
- Repeated targeting of a player
- Doxxing attempts
- Threats to find someone

### Self-Harm Encouragement
- Telling others to hurt themselves
- Suicide references directed at players

---

## 8. False Positive Prevention

The AI is also trained to recognize **safe contexts**:

### Safe Age References
- "how old is this game" ✅
- "that account is 5 years old" ✅
- "my character is level 50" ✅

### Safe Platform References
- "I saw a dizzy video about this game" ⚠️ (still flagged - better safe)
- "this game went viral on insta" ⚠️ (flagged for review)

### Gaming Terms That Look Bad
- "gg" = good game ✅
- "ez" = easy ✅ (might be toxic but not dangerous)
- "noob" = new player ✅

---

## 📝 Contributing

If you discover new bypass patterns, please contribute them!

1. Fork this repository
2. Add the pattern to this document
3. Open a Pull Request

---

## ⚖️ Ethical Note

This research is conducted to **protect children** on Roblox. The patterns documented here are meant to help AI moderation systems detect and prevent:
- Predatory behavior targeting minors
- Hate speech and discrimination
- Platform term violations

**Use this knowledge responsibly.**

---

> 🛡️ SafeGuard AI by @Higanste
