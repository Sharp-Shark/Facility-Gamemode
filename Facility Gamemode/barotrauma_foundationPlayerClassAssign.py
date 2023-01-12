from math import ceil, floor
from random import randint as random

# When hosting, fill this up with the player's names.
playerList = '''
Anne
Ben
Claus
'''

# Set debug to number of test players.
if debug := 6:
    playerList = '\n'
    for n in range(debug) :
        playerList += f'Player {" "*(len(str(debug))-len(str(n+1)))+str(n+1)}\n'
    
playerList = playerList.split('\n')
del(playerList[0])
playerList.pop()

# Generates a distribution of classes
def playerDistribution (n=3) :
    unassigned = n

    monster = ceil(unassigned/4); unassigned -= monster
    
    staff = floor(unassigned/2); unassigned -= staff
    guard = floor(staff/2)
    staff -= floor(staff/2)
    
    inmate = unassigned; unassigned -= inmate

    if unassigned > 0 :
        guard += 1
        unassigned -= 1

    if unassigned > 0 :
        print(f'ERROR - Unassgined player # is {unassigned}!')
    elif unassigned < 0 :
        print(f'ERROR - Exceeded player # by {abs(unassigned)}!')

    return {'monster':monster, 'inmate':inmate, 'staff':staff, 'guard':guard}

# Assigns classes to players
def generatePlayerClass (players) :
    distribution = playerDistribution(len(players))
    print('-|Class Amount|-')
    print(f'Total # of Players is {len(players)}.')
    print(f"Total # of Monsters is {distribution['monster']}.")
    print(f"Total # of Inmates is {distribution['inmate']}.")
    print(f"Total # of Staff is {distribution['staff']}.")
    print(f"Total # of Guards is {distribution['guard']}.")
    print()
    remainingPlayers = players
    playerClass = []

    while len(remainingPlayers) > 0 :
        if distribution['monster'] > 0 :
            index = random(0,len(remainingPlayers)-1)
            playerClass.append((remainingPlayers[index],'monster'))
            del(remainingPlayers[index])
            distribution['monster'] -= 1
        elif distribution['inmate'] > 0 :
            index = random(0,len(remainingPlayers)-1)
            playerClass.append((remainingPlayers[index],'inmate'))
            del(remainingPlayers[index])
            distribution['inmate'] -= 1
        elif distribution['staff'] > 0 :
            index = random(0,len(remainingPlayers)-1)
            playerClass.append((remainingPlayers[index],'staff'))
            del(remainingPlayers[index])
            distribution['staff'] -= 1
        elif distribution['guard'] > 0 :
            index = random(0,len(remainingPlayers)-1)
            playerClass.append((remainingPlayers[index],'guard'))
            del(remainingPlayers[index])
            distribution['guard'] -= 1

    print('-|PLAYER CLASS|-')
    for item in playerClass :
        print(f'{item[0]} is {item[1]}.')
    print()
    return playerClass

# Executes functions
generatePlayerClass(playerList)
    
