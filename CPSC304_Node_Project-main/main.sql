
--Drop statements
DROP TABLE Profession;
DROP TABLE Class;
DROP TABLE Ability;
DROP TABLE Clan;
DROP TABLE GlobalEvent;
DROP TABLE Quest;
DROP TABLE Location;
DROP TABLE NPC;
DROP TABLE EnemySpecies;
DROP TABLE Enemy;
DROP TABLE Item;
DROP TABLE Weapon;
DROP TABLE Drops;
DROP TABLE PlayerLevel;
DROP TABLE Player;
DROP TABLE InInventory;
DROP TABLE IsActive;
DROP TABLE IsFriendsWith;


-- Create statements
CREATE TABLE Profession(
	ProfessionID INT,
	Name VARCHAR(50) NOT NULL UNIQUE,
	Wage INT,
	MinStats VARCHAR(255),
	PRIMARY KEY(ProfessionID)
);

CREATE TABLE Class(
	ClassID INT,
	Name VARCHAR(50) NOT NULL UNIQUE,
	MinLevel INT,
	MaxMana INT,
	PRIMARY KEY(ClassID)
);


CREATE TABLE Ability(
	ClassID INT,
	Name VARCHAR(50),
	ManaCost INT,
	Cooldown FLOAT(24),
	BaseDamage INT,
	BuffsToBaseStats VARCHAR(255),
	PRIMARY KEY(ClassID, Name),
	FOREIGN KEY(ClassID) references Class ON DELETE CASCADE
);


CREATE TABLE Clan(
	ClanName VARCHAR(25),
	MinLevelToJoin INT,
	ClanRank INT,
	NumMembers INT,
	PRIMARY KEY(ClanName)
);


CREATE TABLE GlobalEvent(
	EventID INT,
	Name VARCHAR(50),
	TimeStart TIMESTAMP, 
	TimeEnd TIMESTAMP, 
	EXP_Reward INT, 
	CurrencyReward INT,
	PRIMARY KEY(EventID)
);


CREATE TABLE Quest(
	QuestID INT,
	Name VARCHAR(50),
	MinLevel INT,
	EXP_Reward INT, 
	CurrencyReward INT,
	EventID INT,
	PRIMARY KEY(QuestID),
	FOREIGN KEY(EventID) references GlobalEvent ON DELETE SET NULL
);


CREATE TABLE Location(
	LocationID INT,
	Name VARCHAR(50),
	Terrain VARCHAR(50),
	LocalTime VARCHAR(50),
	LocationLevel INT,
	Weather VARCHAR(50),
	PRIMARY KEY(LocationID)
);


CREATE TABLE NPC(
	NPC_ID INT,
	Name VARCHAR(50),
	NPC_Level INT,
	BaseStats VARCHAR(255),
	LocationID INT NOT NULL,
	PRIMARY KEY(NPC_ID),
	FOREIGN KEY(LocationID) references Location ON DELETE CASCADE
);


CREATE TABLE EnemySpecies(
	EnemySpecies VARCHAR(50),
	SpawnRate FLOAT(24),
	Aggression FLOAT(24),
	EnemyType VARCHAR(50),
	PRIMARY KEY(EnemySpecies)
);


CREATE TABLE Enemy(
	NPC_ID INT,
	EnemySpecies VARCHAR(50) NOT NULL,
	EXPDropped INT,
	GoldDropped INT,
	PRIMARY KEY(NPC_ID),
	FOREIGN KEY(NPC_ID) references NPC ON DELETE CASCADE,
	FOREIGN KEY(EnemySpecies) references EnemySpecies ON DELETE CASCADE
);


CREATE TABLE Item(
	ItemID INT,
	Name VARCHAR(50),
	ItemType VARCHAR(50),
	BaseCost INT,
	PRIMARY KEY(ItemID)
);


CREATE TABLE Weapon(
	ItemID INT,
	WeaponStats VARCHAR(255),
	MinStats VARCHAR(255),
	BuffsToBaseStats VARCHAR(255),
	PRIMARY KEY(ItemID),
	FOREIGN KEY(ItemID) references Item ON DELETE CASCADE
);


CREATE TABLE Drops(
	NPC_ID INT,
	ItemID INT,
	ItemDropRate FLOAT(24),
	PRIMARY KEY(NPC_ID, ItemID),
	FOREIGN KEY(NPC_ID) references Enemy ON DELETE CASCADE,
	FOREIGN KEY(ItemID) references Item ON DELETE CASCADE
);


CREATE TABLE PlayerLevel(
	PlayerLevel INT,
	ClassID INT NOT NULL,
	BaseStats VARCHAR(255),
	PRIMARY KEY(PlayerLevel, ClassID),
	FOREIGN KEY(ClassID) references Class
);


CREATE TABLE Player(
	Username VARCHAR(25),
	PlayerLevel INT NOT NULL,
	Currency INT,
	Mana INT,
	LastSeenOnline TIMESTAMP,
	ProfessionID INT,
	ClassID INT NOT NULL,
	ClanName VARCHAR(25),
	LocationID INT NOT NULL,
	PRIMARY KEY(Username),
	FOREIGN KEY(ProfessionID) references Profession ON DELETE SET NULL,
	FOREIGN KEY(ClassID) references Class,
	FOREIGN KEY(ClanName) references Clan ON DELETE SET NULL,
	FOREIGN KEY(LocationID) references Location,
	FOREIGN KEY(PlayerLevel, ClassID) references PlayerLevel(PlayerLevel, ClassID)
);


CREATE TABLE InInventory(
	Username VARCHAR(25),
	ItemID INT,
	PRIMARY KEY(Username, ItemID),
	FOREIGN KEY(Username) references Player ON DELETE CASCADE,
	FOREIGN KEY(ItemID) references Item ON DELETE CASCADE
);


CREATE TABLE IsActive(
	Username VARCHAR(25),
	QuestID INT,
	PRIMARY KEY(Username, QuestID),
	FOREIGN KEY(Username) references Player ON DELETE CASCADE,
	FOREIGN KEY(QuestID) references Quest ON DELETE CASCADE
);


CREATE TABLE IsFriendsWith(
	Player1 VARCHAR(25),
	Player2 VARCHAR(25),
	PRIMARY KEY(Player1, Player2),
	FOREIGN KEY(Player1) references Player ON DELETE CASCADE,
	FOREIGN KEY(Player2) references Player ON DELETE CASCADE
);

-- Insert statements
INSERT INTO Profession (ProfessionID, Name, Wage, MinStats) VALUES
(1, 'Blacksmith', 120, 'HP: 0, ATK: 12, DEF: 8, SPD: 0'),
(2, 'Alchemist', 110, 'HP: 0, ATK: 0, DEF: 4, SPD: 6'),
(3, 'Hunter', 100, 'HP: 0, ATK: 10, DEF: 0, SPD: 10'),
(4, 'Merchant', 90, 'HP: 0, ATK: 0, DEF: 2, SPD: 8'),
(5, 'Miner', 95, 'HP: 10, ATK: 8, DEF: 10, SPD: 0');


INSERT INTO Class (ClassID, Name, MinLevel, MaxMana) VALUES
(1, 'Warrior', 1, 100),
(2, 'Mage', 1, 220),
(3, 'Archer', 1, 140),
(4, 'Priest', 1, 200),
(5, 'Rogue', 1, 120);

INSERT INTO Ability (ClassID, Name, ManaCost, Cooldown, BaseDamage, BuffsToBaseStats) VALUES
(1, 'Shield Bash', 20, 8.0, 35, 'HP: 0, ATK: 6, DEF: 4, SPD: -1'),
(2, 'Fireball', 35, 5.0, 60, 'HP: 0, ATK: 10, DEF: 0, SPD: 0'),
(3, 'Piercing Arrow', 25, 4.5, 45, 'HP: 0, ATK: 8, DEF: -2, SPD: 2'),
(4, 'Holy Light', 30, 6.0, 25, 'HP: 25, ATK: 0, DEF: 3, SPD: 0'),
(5, 'Backstab', 18, 3.5, 50, 'HP: 0, ATK: 12, DEF: 0, SPD: 4');

INSERT INTO Clan (ClanName, MinLevelToJoin, ClanRank, NumMembers) VALUES
('DragonSlayers', 10, 1, 25),
('MoonGuard', 5, 2, 18),
('ShadowLeaf', 8, 3, 14),
('IronLegion', 12, 4, 20),
('Wanderers', 1, 5, 30);

INSERT INTO GlobalEvent (EventID, Name, TimeStart, TimeEnd, EXP_Reward, CurrencyReward) VALUES
(1, 'Harvest Festival', '2026-03-01 08:00:00', '2026-03-07 23:59:59', 300, 150),
(2, 'Goblin Invasion', '2026-03-10 10:00:00', '2026-03-12 22:00:00', 500, 250),
(3, 'Lunar Eclipse', '2026-03-15 20:00:00', '2026-03-16 02:00:00', 450, 200),
(4, 'Arena Week', '2026-03-18 09:00:00', '2026-03-25 23:59:59', 350, 300),
(5, 'Winter Hunt', '2026-03-28 06:00:00', '2026-04-03 23:59:59', 400, 220);

INSERT INTO Quest (QuestID, Name, MinLevel, EXP_Reward, CurrencyReward, EventID) VALUES
(1, 'Defend the Village', 5, 120, 60, 2),
(2, 'Collect Herbs', 3, 80, 40, 3),
(3, 'Win 3 Arena Matches', 10, 200, 120, 4),
(4, 'Hunt Wolves', 8, 160, 90, 5),
(5, 'Deliver Supplies', 1, 50, 25, 1);

INSERT INTO Location (LocationID, Name, Terrain, LocalTime, LocationLevel, Weather) VALUES
(1, 'Greenhaven', 'Plains', 'Morning', 1, 'Sunny'),
(2, 'Ashen Peak', 'Mountain', 'Noon', 12, 'Windy'),
(3, 'Silverwood', 'Forest', 'Evening', 7, 'Rainy'),
(4, 'Frostfang Keep', 'Tundra', 'Night', 15, 'Snow'),
(5, 'Sunken Marsh', 'Swamp', 'Dusk', 10, 'Foggy');

INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID) VALUES
(1, 'Gruk', 6, 'HP: 120, ATK: 18, DEF: 8, SPD: 6', 1),
(2, 'Emberfang', 14, 'HP: 260, ATK: 40, DEF: 20, SPD: 12', 2),
(3, 'Nightclaw', 9, 'HP: 180, ATK: 24, DEF: 12, SPD: 16', 3),
(4, 'Frostmaw', 16, 'HP: 300, ATK: 45, DEF: 25, SPD: 8', 4),
(5, 'Boglurker', 11, 'HP: 210, ATK: 28, DEF: 14, SPD: 10', 5);

INSERT INTO EnemySpecies (EnemySpecies, SpawnRate, Aggression, EnemyType) VALUES
('Goblin', 0.80, 0.65, 'Humanoid'),
('Fire Drake', 0.25, 0.90, 'Dragon'),
('Dire Wolf', 0.55, 0.75, 'Beast'),
('Ice Troll', 0.30, 0.85, 'Giant'),
('Swamp Slime', 0.70, 0.40, 'Elemental');

INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped) VALUES
(1, 'Goblin', 25, 10),
(2, 'Fire Drake', 120, 55),
(3, 'Dire Wolf', 45, 18),
(4, 'Ice Troll', 140, 65),
(5, 'Swamp Slime', 60, 22);

INSERT INTO Item (ItemID, Name, ItemType, BaseCost) VALUES
(1, 'Iron Sword', 'Weapon', 150),
(2, 'Oak Staff', 'Weapon', 140),
(3, 'Hunter Bow', 'Weapon', 145),
(4, 'Blessed Dagger', 'Weapon', 135),
(5, 'War Hammer', 'Weapon', 170);

INSERT INTO Weapon (ItemID, WeaponStats, MinStats, BuffsToBaseStats) VALUES
(1, 'HP: 0, ATK: 20, DEF: 0, SPD: 0', 'HP: 0, ATK: 10, DEF: 0, SPD: 0', 'HP: 0, ATK: 2, DEF: 0, SPD: 0'),
(2, 'HP: 0, ATK: 16, DEF: 0, SPD: 2', 'HP: 0, ATK: 6, DEF: 0, SPD: 4', 'HP: 0, ATK: 3, DEF: 0, SPD: 1'),
(3, 'HP: 0, ATK: 18, DEF: 0, SPD: 4', 'HP: 0, ATK: 8, DEF: 0, SPD: 8', 'HP: 0, ATK: 2, DEF: 0, SPD: 2'),
(4, 'HP: 0, ATK: 17, DEF: 0, SPD: 6', 'HP: 0, ATK: 7, DEF: 0, SPD: 9', 'HP: 0, ATK: 2, DEF: 0, SPD: 3'),
(5, 'HP: 20, ATK: 24, DEF: 2, SPD: -2', 'HP: 0, ATK: 14, DEF: 4, SPD: 0', 'HP: 10, ATK: 3, DEF: 1, SPD: -1');

INSERT INTO Drops (NPC_ID, ItemID, ItemDropRate) VALUES
(1, 4, 0.20),
(2, 2, 0.15),
(3, 3, 0.25),
(4, 5, 0.10),
(5, 1, 0.18);

INSERT INTO PlayerLevel (PlayerLevel, ClassID, BaseStats) VALUES
(5, 1, 'HP: 180, ATK: 18, DEF: 14, SPD: 6'),
(8, 2, 'HP: 110, ATK: 8, DEF: 6, SPD: 10'),
(7, 3, 'HP: 130, ATK: 16, DEF: 8, SPD: 18'),
(10, 4, 'HP: 140, ATK: 10, DEF: 12, SPD: 10'),
(12, 5, 'HP: 150, ATK: 20, DEF: 10, SPD: 22');

INSERT INTO Player (Username, PlayerLevel, Currency, Mana, LastSeenOnline, ProfessionID, ClassID, ClanName, LocationID) VALUES
('todd', 8, 500, 160, '2026-03-05 18:20:00', 2, 2, 'MoonGuard', 3),
('jonsnow', 5, 220, 55, '2026-03-06 09:10:00', 1, 1, 'Wanderers', 1),
('aegon', 7, 340, 85, '2026-03-04 21:45:00', 3, 3, 'ShadowLeaf', 3),
('walterwhite', 10, 620, 150, '2026-03-06 11:00:00', 4, 4, 'DragonSlayers', 2),
('jesse', 12, 710, 95, '2026-03-05 23:30:00', 5, 5, 'IronLegion', 5);

INSERT INTO InInventory (Username, ItemID) VALUES
('todd', 2),
('jonsnow', 1),
('aegon', 3),
('walterwhite', 5),
('jesse', 4);

INSERT INTO IsActive (Username, QuestID) VALUES
('todd', 2),
('jonsnow', 5),
('aegon', 1),
('walterwhite', 3),
('jesse', 4);

INSERT INTO IsFriendsWith (Player1, Player2) VALUES
('todd', 'aegon'),
('todd', 'walterwhite'),
('jonsnow', 'aegon'),
('aegon', 'jesse'),
('walterwhite', 'jesse');