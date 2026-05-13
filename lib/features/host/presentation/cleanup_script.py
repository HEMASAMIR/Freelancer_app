import os

filepath = r'c:\freelancer\lib\features\host\presentation\listing_management_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# lines are 0-indexed in python, but 1-indexed in the tool
# delete lines 290 to 302 inclusive (1-indexed) -> 289 to 301 (0-indexed)
# actually, let's look at the latest view_file output again
# 289:       },
# 290:         }
# 291:       },
# 292: 
# 293:         if (state is HostAvailabilityLoaded) {
# ...
# 301:         }
# 302:       },
# 303:       child: SingleChildScrollView(

# So we want to keep 289 and delete 290 to 302.
new_lines = lines[:289] + lines[302:]

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
