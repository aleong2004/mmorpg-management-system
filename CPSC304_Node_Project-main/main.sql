-- Drop statements
DROP TABLE IsFriendsWith;
DROP TABLE InInventory;
DROP TABLE IsActive;
DROP TABLE Player;
DROP TABLE PlayerLevel;
DROP TABLE Drops;
DROP TABLE Weapon;
DROP TABLE Item;
DROP TABLE Enemy;
DROP TABLE EnemySpecies;
DROP TABLE NPC;
DROP TABLE Location;
DROP TABLE Quest;
DROP TABLE GlobalEvent;
DROP TABLE Clan;
DROP TABLE Ability;
DROP TABLE Class;
DROP TABLE Profession;

-- Create statements
CREATE TABLE Profession (
	ProfessionID INT,
	Name VARCHAR(50) NOT NULL UNIQUE,
	Wage INT,
	MinStats VARCHAR(255),
	PRIMARY KEY(ProfessionID)
);

CREATE TABLE Class (
	ClassID INT,
	Name VARCHAR(50) NOT NULL UNIQUE,
	MinLevel INT,
	MaxMana INT,
	PRIMARY KEY(ClassID)
);


CREATE TABLE Ability (
	ClassID INT,
	Name VARCHAR(50),
	ManaCost INT,
	Cooldown FLOAT(24),
	BaseDamage INT,
	BuffsToBaseStats VARCHAR(255),
	PRIMARY KEY(ClassID, Name),
	FOREIGN KEY(ClassID) references Class ON DELETE CASCADE
);


CREATE TABLE Clan (
	ClanName VARCHAR(30),
	MinLevelToJoin INT,
	ClanRank INT,
	NumMembers INT,
	PRIMARY KEY(ClanName)
);


CREATE TABLE GlobalEvent (
	EventID INT,
	Name VARCHAR(50),
	TimeStart TIMESTAMP, 
	TimeEnd TIMESTAMP, 
	EXP_Reward INT, 
	CurrencyReward INT,
	PRIMARY KEY(EventID)
);


CREATE TABLE Quest (
	QuestID INT,
	Name VARCHAR(50),
	MinLevel INT,
	EXP_Reward INT, 
	CurrencyReward INT,
	EventID INT,
	PRIMARY KEY(QuestID),
	FOREIGN KEY(EventID) references GlobalEvent ON DELETE SET NULL
);


CREATE TABLE Location (
	LocationID INT,
	Name VARCHAR(50),
	Terrain VARCHAR(50),
	LocalTime VARCHAR(50),
	LocationLevel INT,
	Weather VARCHAR(50),
	PRIMARY KEY(LocationID)
);


CREATE TABLE NPC (
	NPC_ID INT,
	Name VARCHAR(50),
	NPC_Level INT,
	BaseStats VARCHAR(255),
	LocationID INT NOT NULL,
	PRIMARY KEY(NPC_ID),
	FOREIGN KEY(LocationID) references Location ON DELETE CASCADE
);


CREATE TABLE EnemySpecies (
	EnemySpecies VARCHAR(50),
	SpawnRate FLOAT(24),
	Aggression FLOAT(24),
	EnemyType VARCHAR(50),
	PRIMARY KEY(EnemySpecies)
);


CREATE TABLE Enemy (
	NPC_ID INT,
	EnemySpecies VARCHAR(50) NOT NULL,
	EXPDropped INT,
	GoldDropped INT,
	PRIMARY KEY(NPC_ID),
	FOREIGN KEY(NPC_ID) references NPC ON DELETE CASCADE,
	FOREIGN KEY(EnemySpecies) references EnemySpecies ON DELETE CASCADE
);


CREATE TABLE Item (
	ItemID INT,
	Name VARCHAR(50),
	ItemType VARCHAR(50),
	BaseCost INT,
	PRIMARY KEY(ItemID)
);


CREATE TABLE Weapon (
	ItemID INT,
	WeaponStats VARCHAR(255),
	MinStats VARCHAR(255),
	BuffsToBaseStats VARCHAR(255),
	PRIMARY KEY(ItemID),
	FOREIGN KEY(ItemID) references Item ON DELETE CASCADE
);


CREATE TABLE Drops (
	NPC_ID INT,
	ItemID INT,
	ItemDropRate FLOAT(24),
	PRIMARY KEY(NPC_ID, ItemID),
	FOREIGN KEY(NPC_ID) references Enemy ON DELETE CASCADE,
	FOREIGN KEY(ItemID) references Item ON DELETE CASCADE
);


CREATE TABLE PlayerLevel (
	PlayerLevel INT,
	ClassID INT NOT NULL,
	BaseStats VARCHAR(255),
	PRIMARY KEY(PlayerLevel, ClassID),
	FOREIGN KEY(ClassID) references Class
);


CREATE TABLE Player (
	Username VARCHAR(25),
	PlayerLevel INT NOT NULL,
	Currency INT,
	Mana INT,
	LastSeenOnline TIMESTAMP,
	ProfessionID INT,
	ClassID INT NOT NULL,
	ClanName VARCHAR(30),
	LocationID INT NOT NULL,
	PRIMARY KEY(Username),
	FOREIGN KEY(ProfessionID) references Profession ON DELETE SET NULL,
	FOREIGN KEY(ClassID) references Class,
	FOREIGN KEY(ClanName) references Clan ON DELETE SET NULL,
	FOREIGN KEY(LocationID) references Location,
	FOREIGN KEY(PlayerLevel, ClassID) references PlayerLevel(PlayerLevel, ClassID)
);


CREATE TABLE InInventory (
	Username VARCHAR(25),
	ItemID INT,
	PRIMARY KEY(Username, ItemID),
	FOREIGN KEY(Username) references Player ON DELETE CASCADE,
	FOREIGN KEY(ItemID) references Item ON DELETE CASCADE
);


CREATE TABLE IsActive (
	Username VARCHAR(25),
	QuestID INT,
	PRIMARY KEY(Username, QuestID),
	FOREIGN KEY(Username) references Player ON DELETE CASCADE,
	FOREIGN KEY(QuestID) references Quest ON DELETE CASCADE
);


CREATE TABLE IsFriendsWith (
	Player1 VARCHAR(25),
	Player2 VARCHAR(25),
	PRIMARY KEY(Player1, Player2),
	FOREIGN KEY(Player1) references Player ON DELETE CASCADE,
	FOREIGN KEY(Player2) references Player ON DELETE CASCADE
);

-- Insert statements
INSERT INTO Profession (ProfessionID, Name, Wage, MinStats) VALUES (1, 'Blacksmith', 120, 'HP: 0, ATK: 12, DEF: 8, SPD: 0');
INSERT INTO Profession (ProfessionID, Name, Wage, MinStats) VALUES (2, 'Alchemist', 110, 'HP: 0, ATK: 0, DEF: 4, SPD: 6');
INSERT INTO Profession (ProfessionID, Name, Wage, MinStats) VALUES (3, 'Hunter', 100, 'HP: 0, ATK: 10, DEF: 0, SPD: 10');
INSERT INTO Profession (ProfessionID, Name, Wage, MinStats) VALUES (4, 'Merchant', 90, 'HP: 0, ATK: 0, DEF: 2, SPD: 8');
INSERT INTO Profession (ProfessionID, Name, Wage, MinStats) VALUES (5, 'Miner', 95, 'HP: 10, ATK: 8, DEF: 10, SPD: 0');

INSERT INTO Class (ClassID, Name, MinLevel, MaxMana) VALUES (1, 'Warrior', 1, 100);
INSERT INTO Class (ClassID, Name, MinLevel, MaxMana) VALUES (2, 'Mage', 1, 220);
INSERT INTO Class (ClassID, Name, MinLevel, MaxMana) VALUES (3, 'Archer', 1, 140);
INSERT INTO Class (ClassID, Name, MinLevel, MaxMana) VALUES (4, 'Priest', 1, 200);
INSERT INTO Class (ClassID, Name, MinLevel, MaxMana) VALUES (5, 'Rogue', 1, 120);

INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (1, 'Shield Bash', 20, 8.0, 35, 'HP: 0, ATK: 6, DEF: 4, SPD: -1');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (2, 'Fireball', 35, 5.0, 60, 'HP: 0, ATK: 10, DEF: 0, SPD: 0');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (3, 'Piercing Arrow', 25, 4.5, 45, 'HP: 0, ATK: 8, DEF: -2, SPD: 2');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (4, 'Holy Light', 30, 6.0, 25, 'HP: 25, ATK: 0, DEF: 3, SPD: 0');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (5, 'Backstab', 18, 3.5, 50, 'HP: 0, ATK: 12, DEF: 0, SPD: 4');

-- Additional abilities per class for our JOIN query
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (1, 'Fast Blade', 30, 12.0, 20, 'HP: 0, ATK: 10, DEF: 0, SPD: 0');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (1, 'Whirl wind', 40, 10.0, 55, 'HP: 0, ATK: 8, DEF: -2, SPD: 0');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (2, 'Super Nova', 45, 8.0, 50, 'HP: 0, ATK: 0, DEF: 0, SPD: -4');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (2, 'Butane Blast', 50, 6.0, 75, 'HP: 0, ATK: 12, DEF: 0, SPD: 0');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (3, 'Rain of Arrows', 35, 9.0, 60, 'HP: 0, ATK: 6, DEF: 0, SPD: 0');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (3, 'Eagle Eye', 20, 7.0, 40, 'HP: 0, ATK: 10, DEF: -1, SPD: 3');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (4, 'Divine Shield', 40, 15.0, 0, 'HP: 50, ATK: 0, DEF: 10, SPD: 0');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (4, 'Smite', 25, 4.0, 40, 'HP: 0, ATK: 8, DEF: 0, SPD: 0');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (5, 'Shadow Step', 22, 5.0, 35, 'HP: 0, ATK: 0, DEF: 0, SPD: 10');
INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES (5, 'Poison Blade', 28, 6.5, 45, 'HP: 0, ATK: 8, DEF: 0, SPD: 2');

INSERT INTO Clan (ClanName, MinLevelToJoin, ClanRank, NumMembers) VALUES ('DragonSlayers', 10, 1, 25);
INSERT INTO Clan (ClanName, MinLevelToJoin, ClanRank, NumMembers) VALUES ('MoonGuard', 5, 2, 18);
INSERT INTO Clan (ClanName, MinLevelToJoin, ClanRank, NumMembers) VALUES ('ShadowLeaf', 8, 3, 14);
INSERT INTO Clan (ClanName, MinLevelToJoin, ClanRank, NumMembers) VALUES ('IronLegion', 12, 4, 20);
INSERT INTO Clan (ClanName, MinLevelToJoin, ClanRank, NumMembers) VALUES ('Wanderers', 1, 5, 30);
INSERT INTO Clan (ClanName, MinLevelToJoin, ClanRank, NumMembers) VALUES ('Super Awesome Cool Guy Squad', 1, 6, 5);

INSERT INTO GlobalEvent (EventID, Name, TimeStart, TimeEnd, EXP_Reward, CurrencyReward) VALUES (1, 'Harvest Festival', TO_TIMESTAMP('2026-03-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-03-07 23:59:59', 'YYYY-MM-DD HH24:MI:SS'), 300, 150);
INSERT INTO GlobalEvent (EventID, Name, TimeStart, TimeEnd, EXP_Reward, CurrencyReward) VALUES (2, 'Goblin Invasion', TO_TIMESTAMP('2026-03-10 10:00:00', 'YYYY-MM-DD HH24:MI:SS'),  TO_TIMESTAMP('2026-03-12 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 500, 250);
INSERT INTO GlobalEvent (EventID, Name, TimeStart, TimeEnd, EXP_Reward, CurrencyReward) VALUES (3, 'Lunar Eclipse', TO_TIMESTAMP('2026-03-15 20:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-03-16 02:00:00', 'YYYY-MM-DD HH24:MI:SS'), 450, 200);
INSERT INTO GlobalEvent (EventID, Name, TimeStart, TimeEnd, EXP_Reward, CurrencyReward) VALUES (4, 'Arena Week', TO_TIMESTAMP('2026-03-18 09:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-03-25 23:59:59', 'YYYY-MM-DD HH24:MI:SS'), 350, 300);
INSERT INTO GlobalEvent (EventID, Name, TimeStart, TimeEnd, EXP_Reward, CurrencyReward) VALUES (5, 'Winter Hunt', TO_TIMESTAMP('2026-03-28 06:00:00', 'YYYY-MM-DD HH24:MI:SS'), TO_TIMESTAMP('2026-04-03 23:59:59', 'YYYY-MM-DD HH24:MI:SS'), 400, 220);

INSERT INTO Quest (QuestID, Name, MinLevel, EXP_Reward, CurrencyReward, EventID) VALUES (1, 'Defend the Village', 5, 120, 60, 2);
INSERT INTO Quest (QuestID, Name, MinLevel, EXP_Reward, CurrencyReward, EventID) VALUES (2, 'Collect Herbs', 3, 80, 40, 3);
INSERT INTO Quest (QuestID, Name, MinLevel, EXP_Reward, CurrencyReward, EventID) VALUES (3, 'Win 3 Arena Matches', 10, 200, 120, 4);
INSERT INTO Quest (QuestID, Name, MinLevel, EXP_Reward, CurrencyReward, EventID) VALUES (4, 'Hunt Wolves', 8, 160, 90, 5);
INSERT INTO Quest (QuestID, Name, MinLevel, EXP_Reward, CurrencyReward, EventID) VALUES (5, 'Deliver Supplies', 1, 50, 25, 1);


INSERT INTO Location (LocationID, Name, Terrain, LocalTime, LocationLevel, Weather) VALUES (1, 'Greenhaven', 'Plains', 'Morning', 1, 'Sunny');
INSERT INTO Location (LocationID, Name, Terrain, LocalTime, LocationLevel, Weather) VALUES (2, 'Ashen Peak', 'Mountain', 'Noon', 12, 'Windy');
INSERT INTO Location (LocationID, Name, Terrain, LocalTime, LocationLevel, Weather) VALUES (3, 'Silverwood', 'Forest', 'Evening', 7, 'Rainy');
INSERT INTO Location (LocationID, Name, Terrain, LocalTime, LocationLevel, Weather) VALUES (4, 'Frostfang Keep', 'Tundra', 'Night', 15, 'Snow');
INSERT INTO Location (LocationID, Name, Terrain, LocalTime, LocationLevel, Weather) VALUES (5, 'Sunken Marsh', 'Swamp', 'Dusk', 10, 'Foggy');

INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (1, 'Gruk', 6, 'HP: 120, ATK: 18, DEF: 8, SPD: 6', 1);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (2, 'Emberfang', 14, 'HP: 260, ATK: 40, DEF: 20, SPD: 12', 2);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (3, 'Nightclaw', 9, 'HP: 180, ATK: 24, DEF: 12, SPD: 16', 3);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (4, 'Frostmaw', 16, 'HP: 300, ATK: 45, DEF: 25, SPD: 8', 4);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (5, 'Boglurker', 11, 'HP: 210, ATK: 28, DEF: 14, SPD: 10', 5);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (6, 'Saul Goodman', 60, 'HP: 1500, ATK: 300, DEF: 67, SPD: 167', 1);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (7, 'Elder Dragon', 55, 'HP: 10000, ATK: 99, DEF: 420, SPD: 35', 2);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (8, 'Atakhan', 35, 'HP: 4400, ATK: 60, DEF: 130, SPD: 48', 5);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (9, 'Gromp', 8, 'HP: 240, ATK: 9, DEF: 10, SPD: 4', 5);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (10, 'Treant', 18, 'HP: 500, ATK: 29, DEF: 34, SPD: 10', 3);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (11, 'Hobgoblin', 9, 'HP: 200, ATK: 22, DEF: 10, SPD: 8', 1);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (12, 'Orc', 13, 'HP: 333, ATK: 40, DEF: 25, SPD: 6', 1);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (13, 'Jerry', 3, 'HP: 50, ATK: 6, DEF: 3, SPD: 9', 1);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (14, 'Wind Spirit', 10, 'HP: 80, ATK: 17, DEF: 8, SPD: 30', 2);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (15, 'Bandit', 15, 'HP: 250, ATK: 31, DEF: 17, SPD: 24', 3);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (16, 'Bandit Leader', 20, 'HP: 350, ATK: 44, DEF: 40, SPD: 24', 3);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (17, 'Fenrir', 46, 'HP: 2500, ATK: 85, DEF: 100, SPD: 150', 4);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (18, 'Snowfox', 14, 'HP: 222, ATK: 30, DEF: 13, SPD: 28', 4);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (19, 'Winter Rabbit', 12, 'HP: 167, ATK: 19, DEF: 11, SPD: 25', 4);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (20, 'Lost Spirit', 15, 'HP: 300, ATK: 32, DEF: 25, SPD: 20', 5);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (21, 'Gustavo Fring', 27, 'HP: 666, ATK: 66, DEF: 66, SPD: 66', 5);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (22, 'Troll', 19, 'HP: 444, ATK: 46, DEF: 30, SPD: 27', 5);
INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES (23, 'Ogre', 23, 'HP: 750, ATK: 99, DEF: 67, SPD: 13', 5);

INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Goblin', 0.80, 0.65, 'Humanoid');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Fire Drake', 0.25, 0.90, 'Dragon');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Dire Wolf', 0.55, 0.75, 'Beast');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Ice Troll', 0.30, 0.85, 'Giant');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Swamp Slime', 0.70, 0.40, 'Elemental');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Elder Dragon', 0.00, 0.99, 'Dragon');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Atakhan', 0.01, 0.99, 'Elemental');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Giant Frog', 0.95, 0.25, 'Beast');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Treant', 0.15, 0.66, 'Plant');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Spirit', 0.45, 0.60, 'Elemental');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Bandit', 0.50, 0.50, 'Humanoid');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Bandit Leader', 0.00, 0.60, 'Humanoid');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Fenrir', 0.00, 0.30, 'Beast');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Fox', 0.40, 0.21, 'Beast');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Rabbit', 0.63, 0.12, 'Beast');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Troll', 0.33, 0.70, 'Humanoid');
INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES ('Ogre', 0.20, 0.65, 'Humanoid');

INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (1, 'Goblin', 25, 10);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (2, 'Fire Drake', 120, 55);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (3, 'Dire Wolf', 45, 18);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (4, 'Ice Troll', 140, 65);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (5, 'Swamp Slime', 60, 22);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (7, 'Elder Dragon', 10000, 100000);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (8, 'Atakhan', 1000, 780);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (9, 'Giant Frog', 40, 5);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (10, 'Treant', 170, 37);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (11, 'Goblin', 50, 15);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (12, 'Goblin', 99, 31);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (14, 'Spirit', 57, 14);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (15, 'Bandit', 111, 256);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (16, 'Bandit Leader', 350, 2148);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (17, 'Fenrir', 2500, 8000);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (18, 'Fox', 121, 49);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (19, 'Rabbit', 101, 41);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (20, 'Spirit', 133, 88);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (22, 'Troll', 207, 123);
INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES (23, 'Ogre', 369, 131);

INSERT INTO Item (ItemID, Name, ItemType, BaseCost) VALUES (1, 'Iron Sword', 'Weapon', 150);
INSERT INTO Item (ItemID, Name, ItemType, BaseCost) VALUES (2, 'Oak Staff', 'Weapon', 140);
INSERT INTO Item (ItemID, Name, ItemType, BaseCost) VALUES (3, 'Hunter Bow', 'Weapon', 145);
INSERT INTO Item (ItemID, Name, ItemType, BaseCost) VALUES (4, 'Blessed Dagger', 'Weapon', 135);
INSERT INTO Item (ItemID, Name, ItemType, BaseCost) VALUES (5, 'War Hammer', 'Weapon', 170);

INSERT INTO Weapon (ItemID, WeaponStats, MinStats, BuffsToBaseStats) VALUES (1, 'HP: 0, ATK: 20, DEF: 0, SPD: 0', 'HP: 0, ATK: 10, DEF: 0, SPD: 0', 'HP: 0, ATK: 2, DEF: 0, SPD: 0');
INSERT INTO Weapon (ItemID, WeaponStats, MinStats, BuffsToBaseStats) VALUES (2, 'HP: 0, ATK: 16, DEF: 0, SPD: 2', 'HP: 0, ATK: 6, DEF: 0, SPD: 4', 'HP: 0, ATK: 3, DEF: 0, SPD: 1');
INSERT INTO Weapon (ItemID, WeaponStats, MinStats, BuffsToBaseStats) VALUES (3, 'HP: 0, ATK: 18, DEF: 0, SPD: 4', 'HP: 0, ATK: 8, DEF: 0, SPD: 8', 'HP: 0, ATK: 2, DEF: 0, SPD: 2');
INSERT INTO Weapon (ItemID, WeaponStats, MinStats, BuffsToBaseStats) VALUES (4, 'HP: 0, ATK: 17, DEF: 0, SPD: 6', 'HP: 0, ATK: 7, DEF: 0, SPD: 9', 'HP: 0, ATK: 2, DEF: 0, SPD: 3');
INSERT INTO Weapon (ItemID, WeaponStats, MinStats, BuffsToBaseStats) VALUES (5, 'HP: 20, ATK: 24, DEF: 2, SPD: -2', 'HP: 0, ATK: 14, DEF: 4, SPD: 0', 'HP: 10, ATK: 3, DEF: 1, SPD: -1');

INSERT INTO Drops (NPC_ID, ItemID, ItemDropRate) VALUES (1, 4, 0.20);
INSERT INTO Drops (NPC_ID, ItemID, ItemDropRate) VALUES (2, 2, 0.15);
INSERT INTO Drops (NPC_ID, ItemID, ItemDropRate) VALUES (3, 3, 0.25);
INSERT INTO Drops (NPC_ID, ItemID, ItemDropRate) VALUES (4, 5, 0.10);
INSERT INTO Drops (NPC_ID, ItemID, ItemDropRate) VALUES (5, 1, 0.18);

INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (5, 1, 'HP: 180, ATK: 18, DEF: 14, SPD: 6');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (8, 2, 'HP: 110, ATK: 8, DEF: 6, SPD: 10');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (7, 3, 'HP: 130, ATK: 16, DEF: 8, SPD: 18');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (10, 4, 'HP: 140, ATK: 10, DEF: 12, SPD: 10');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (12, 5, 'HP: 150, ATK: 20, DEF: 10, SPD: 22');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (3, 1, 'HP: 100, ATK: 9, DEF: 7, SPD: 4');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (6, 4, 'HP: 80, ATK: 5, DEF: 5, SPD: 6');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (5, 3, 'HP: 90, ATK: 10, DEF: 5, SPD: 13');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (9, 3, 'HP: 185, ATK: 26, DEF: 12, SPD: 23');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (27, 5, 'HP: 500, ATK: 83, DEF: 35, SPD: 73');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (15, 4, 'HP: 320, ATK: 17, DEF: 21, SPD: 16');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (19, 4, 'HP: 600, ATK: 25, DEF: 39, SPD: 21');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (11, 5, 'HP: 135, ATK: 18, DEF: 9, SPD: 20');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (14, 2, 'HP: 230, ATK: 47, DEF: 13, SPD: 28');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (14, 3, 'HP: 420, ATK: 61, DEF: 26, SPD: 32');
INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES (45, 1, 'HP: 1500, ATK: 191, DEF: 223, SPD: 56');

INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('todd', 8, 500, 160, TO_TIMESTAMP('2026-03-05 18:20:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 2, 'MoonGuard', 3);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('jonsnow', 5, 220, 55, TO_TIMESTAMP('2026-03-06 09:10:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 1, 'Wanderers', 1);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('aegon', 7, 340, 85, TO_TIMESTAMP('2026-03-04 21:45:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 3, 'ShadowLeaf', 3);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('walterwhite', 10, 620, 150, TO_TIMESTAMP('2026-03-06 11:00:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 4, 'DragonSlayers', 2);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('jesse', 12, 710, 95, TO_TIMESTAMP('2026-03-05 23:30:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 5, 'IronLegion', 5);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('awesomeguy1', 3, 18, 100, TO_TIMESTAMP('2026-03-22 21:40:00', 'YYYY-MM-DD HH24:MI:SS'), 3, 1, 'Super Awesome Cool Guy Squad', 1);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('awesomeguy2', 6, 312, 21, TO_TIMESTAMP('2026-03-22 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 4, 'Super Awesome Cool Guy Squad', 1);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('awesomeguy3', 5, 343, 17, TO_TIMESTAMP('2026-03-22 21:30:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 3, 'Super Awesome Cool Guy Squad', 1);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('awesomeguy4', 9, 565, 175, TO_TIMESTAMP('2026-03-22 21:45:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 3, 'Super Awesome Cool Guy Squad', 5);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('Michael Scott', 6, 677, 67, TO_TIMESTAMP('2026-03-25 16:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 4, 'Super Awesome Cool Guy Squad', 5);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('TheLegend27', 27, 329, 600, TO_TIMESTAMP('2026-03-30 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 5, NULL, 5);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('Tyler Ninja Blevins', 15, 2581, 240, TO_TIMESTAMP('2026-03-19 19:45:00', 'YYYY-MM-DD HH24:MI:SS'), 1, 4, NULL, 3);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('johngamer', 19, 1188, 321, TO_TIMESTAMP('2026-04-01 21:44:30', 'YYYY-MM-DD HH24:MI:SS'), 4, 4, NULL, 3);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('aaaaaa', 11, 246, 180, TO_TIMESTAMP('2026-03-31 02:30:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 5, NULL, 2);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('kaicenat', 14, 923, 46, TO_TIMESTAMP('2026-03-17 21:01:00', 'YYYY-MM-DD HH24:MI:SS'), 4, 2, NULL, 5);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('ishowspeed', 14, 895, 103, TO_TIMESTAMP('2026-03-17 21:00:00', 'YYYY-MM-DD HH24:MI:SS'), 5, 3, NULL, 5);
INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES ('fortnite', 45, 24020, 1200, TO_TIMESTAMP('2026-04-02 22:00:00', 'YYYY-MM-DD HH24:MI:SS'), 2, 1, NULL, 4);

INSERT INTO InInventory (Username, ItemID) VALUES ('todd', 2);
INSERT INTO InInventory (Username, ItemID) VALUES ('jonsnow', 1);
INSERT INTO InInventory (Username, ItemID) VALUES ('aegon', 3);
INSERT INTO InInventory (Username, ItemID) VALUES ('walterwhite', 5);
INSERT INTO InInventory (Username, ItemID) VALUES ('jesse', 4);

INSERT INTO IsActive (Username, QuestID) VALUES ('todd', 2);
INSERT INTO IsActive (Username, QuestID) VALUES ('jonsnow', 5);
INSERT INTO IsActive (Username, QuestID) VALUES ('aegon', 1);
INSERT INTO IsActive (Username, QuestID) VALUES ('walterwhite', 3);
INSERT INTO IsActive (Username, QuestID) VALUES ('jesse', 4);

INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('todd', 'aegon');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('todd', 'walterwhite');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('jonsnow', 'aegon');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('aegon', 'jesse');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('walterwhite', 'jesse');

-- Michael Scott is friends with all other clan members so this basically satisfies our division
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('Michael Scott', 'awesomeguy1');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('Michael Scott', 'awesomeguy2');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('Michael Scott', 'awesomeguy3');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('Michael Scott', 'awesomeguy4');

INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('awesomeguy1', 'Michael Scott');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('awesomeguy1', 'awesomeguy3');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('awesomeguy1', 'awesomeguy4');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('awesomeguy1', 'awesomeguy2');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('awesomeguy2', 'awesomeguy3');
INSERT INTO IsFriendsWith (Player1, Player2) VALUES ('awesomeguy3', 'awesomeguy4');