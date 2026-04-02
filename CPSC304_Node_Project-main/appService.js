const oracledb = require('oracledb');
const loadEnvFile = require('./utils/envUtil');
const fs = require("fs");

const envVariables = loadEnvFile('./.env');

// Database configuration setup. Ensure your .env file has the required database credentials.
const dbConfig = {
    user: envVariables.ORACLE_USER,
    password: envVariables.ORACLE_PASS,
    connectString: `${envVariables.ORACLE_HOST}:${envVariables.ORACLE_PORT}/${envVariables.ORACLE_DBNAME}`,
    poolMin: 1,
    poolMax: 3,
    poolIncrement: 1,
    poolTimeout: 60
};

// initialize connection pool
async function initializeConnectionPool() {
    try {
        await oracledb.createPool(dbConfig);
        console.log('Connection pool started');
    } catch (err) {
        console.error('Initialization error: ' + err.message);
    }
}

async function closePoolAndExit() {
    console.log('\nTerminating');
    try {
        await oracledb.getPool().close(10); // 10 seconds grace period for connections to finish
        console.log('Pool closed');
        process.exit(0);
    } catch (err) {
        console.error(err.message);
        process.exit(1);
    }
}

initializeConnectionPool();

process
    .once('SIGTERM', closePoolAndExit)
    .once('SIGINT', closePoolAndExit);


// ----------------------------------------------------------
// Wrapper to manage OracleDB actions, simplifying connection handling.
async function withOracleDB(action) {
    let connection;
    try {
        connection = await oracledb.getConnection(); // Gets a connection from the default pool 
        return await action(connection);
    } catch (err) {
        console.error(err);
        throw err;
    } finally {
        if (connection) {
            try {
                await connection.close();
            } catch (err) {
                console.error(err);
            }
        }
    }
}


// ----------------------------------------------------------
// Core functions for database operations
// Modify these functions, especially the SQL queries, based on your project's requirements and design.
async function testOracleConnection() {
    return await withOracleDB(async (connection) => {
        return true;
    }).catch(() => {
        return false;
    });
}

async function fetchDemotableFromDb() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT * FROM DEMOTABLE');
        return result.rows;
    }).catch(() => {
        return [];
    });
}

async function fetchPlayerData() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT p.Username, p.PlayerLevel, pl.BaseStats, p.Currency, p.Mana, 
                    p.LastSeenOnline, p.ProfessionID, prof.Name, p.ClassID, 
                    c.Name, p.ClanName, p.LocationID, loc.Name
             FROM Player p, PlayerLevel pl, Location loc, Profession prof, Class c
             WHERE p.ProfessionID = prof.ProfessionID AND
                   p.ClassID = c.ClassID AND
                   p.LocationID = loc.LocationID AND
                   p.PlayerLevel = pl.PlayerLevel AND
                   p.ClassID = pl.ClassID`
            );
        return result.rows;
    }).catch(() => {
        return [];
    });
}

async function initiateDemotable() {
    return await withOracleDB(async (connection) => {
        try {
            await connection.execute(`DROP TABLE DEMOTABLE`);
        } catch(err) {
            console.log('Table might not exist, proceeding to create...');
        }

        const result = await connection.execute(`
            CREATE TABLE DEMOTABLE (
                id NUMBER PRIMARY KEY,
                name VARCHAR2(20)
            )
        `);
        return true;
    }).catch(() => {
        return false;
    });
}

async function reloadDB() {
    return await withOracleDB(async (connection) => {
        const filename = "main.sql";
        const split_location = "-- Create statements";
        let sql_script = fs.readFileSync(filename, "utf-8").split(split_location);
        let drop_tables = sql_script[0].split(";").map(str => str.trim()).filter(str => str !== "");
        let create_tables_and_tuples = sql_script[1].split(";").map(str => str.trim()).filter(str => str !== "");
        try {
            for (const drop_table_statement of drop_tables) {
                await connection.execute(drop_table_statement);
            }
        } catch(err) {
            console.log("Error in DROP TABLE statement: ", err);
        }

        for (const sql_statement of create_tables_and_tuples) {
            const result = await connection.execute(sql_statement, [], { autoCommit: true });
        }
        return true;
    }).catch(() => {
        return false;
    });
}

async function insertDemotable(id, name) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `INSERT INTO DEMOTABLE (id, name) VALUES (:id, :name)`,
            [id, name],
            { autoCommit: true }
        );

        return result.rowsAffected && result.rowsAffected > 0;
    }).catch(() => {
        return false;
    });
}

async function updateNameDemotable(oldName, newName) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `UPDATE DEMOTABLE SET name=:newName where name=:oldName`,
            [newName, oldName],
            { autoCommit: true }
        );

        return result.rowsAffected && result.rowsAffected > 0;
    }).catch(() => {
        return false;
    });
}

async function countDemotable() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute('SELECT Count(*) FROM DEMOTABLE');
        return result.rows[0][0];
    }).catch(() => {
        return -1;
    });
}

// fetching enemy data so user can update based on this
async function fetchEnemyData() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT e.NPC_ID, n.Name, e.EnemySpecies, e.EXPDropped, e.GoldDropped
            FROM Enemy e
            JOIN NPC n
            ON e.NPC_ID = n.NPC_ID`
        );
        return result.rows;

    }).catch(() => {
        return [];
    });
    
}

async function updateEnemy(npcId, enemySpecies, expDropped, goldDropped) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `UPDATE Enemy
            SET EnemySpecies = :enemySpecies,
                EXPDropped = :expDropped,
                GoldDropped = :goldDropped
            WHERE NPC_ID = :npcId`,
            { enemySpecies, expDropped, goldDropped, npcId },
            { autoCommit: true}
        );
        return result.rowsAffected && result.rowsAffected > 0;

    }).catch(() => {
        return false;
    });
    
}

async function getPlayerAbilities(username) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT p.Username, c.Name AS ClassName, a.Name AS AbilityName,
                    a.ManaCost, a.Cooldown, a.BaseDamage
            FROM Player p
            JOIN Class c ON p.ClassID = c.ClassID
            JOIN Ability a ON c.ClassID = a.ClassID
            WHERE p.Username = :username`,
            { username }
        );
        return result.rows;
    }).catch(() => {
        return [];
    });
    
}

async function getPlayersfriendsWithAllClanMembers() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `SELECT p.Username, p.ClanName, cl.ClanRank, cl.NumMembers
            FROM Player p
            JOIN Clan cl ON p.ClanName = cl.ClanName
            WHERE p.ClanName IS NOT NULL
            AND (SELECT COUNT(*) FROM Player p3 WHERE p3.ClanName = p.ClanName) > 1
            AND NOT EXISTS (
                    SELECT p2.Username
                    FROM Player p2
                    WHERE p2.ClanName = p.ClanName
                    AND p2.Username != p.Username
                    MINUS
                    SELECT f.Player2
                    FROM IsFriendsWith f
                    WHERE f.Player1 = p.Username)`
        );
        return result.rows;
    }).catch(() => {
        return [];
    });
}
// STUFF

// Insert query
async function insertEnemy(npcId, enemySpecies, expDropped, goldDropped, name, npcLevel, baseStats, locationId) {
    return await withOracleDB(async (connection) => {

        //reject if no loc
        const locationCheck = await connection.execute(`SELECT * FROM Location WHERE LocationID = :locationId`, [locationId]);
        if (locationCheck.rows.length === 0) { return false; }

        //create NPC if pcId doesn't match
        const npcCheck = await connection.execute(`SELECT * FROM NPC WHERE NPC_ID = :npcId`, [npcId]);
        if (npcCheck.rows.length === 0) {
            await connection.execute(
                `INSERT INTO NPC (NPC_ID, Name, NPC_Level, BaseStats, LocationID)
                 VALUES (:npcId, :name, :npcLevel, :baseStats, :locationId)`,
                [npcId, name, npcLevel, baseStats, locationId],
                { autoCommit: false }
            );
        }

        //enemy tsert
        await connection.execute(
            `INSERT INTO Enemy (NPC_ID, EnemySpecies, EXPDropped, GoldDropped)
             VALUES (:npcId, :enemySpecies, :expDropped, :goldDropped)`,
            [npcId, enemySpecies, expDropped, goldDropped],
            { autoCommit: true }
        );

        return true;
    }).catch(() => {
        return false;
    });
}

//delete query
async function deleteItem(itemId) {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `DELETE FROM Item WHERE ItemID = : itemId`,
            [itemId],
            { autoCommit: true }
        );

        return result.rowsAffected && result.rowsAffected > 0;
    }).catch(() => {
        return false;
    });
}

// ordering is an array of strings, each string is a column to be returned (in order)
async function questProjection(ordering) {
    return await withOracleDB(async (connection) => {
        console.log(ordering);
        const allowedCols = ["QuestID", "Name", "MinLevel", "EXP_Reward", "CurrencyReward", "EventID"];
        if (ordering.length === 0) {
            return -1;
        }
        for (const order of ordering) {
            if (!allowedCols.includes(order)) {
                return -2;
            }
        }
        const result = await connection.execute(
            `SELECT ${ordering.join(", ")} FROM Quest`
        );
        console.log(result.rows);
        return result.rows;
    }).catch(() => {
        return false;
    });
}

// condList is an array, each element in condList is an array of length 4.
// First element is the condition AND/OR, second element is the attribute,
// third element is the inequality, fourth element is the value
async function selectPlayers(condList) {
    return await withOracleDB(async (connection) => {
        console.log(condList);
        const conds = ["AND", "OR"];
        const columns = [
            "p.Username", "p.PlayerLevel", "pl.BaseStats", "p.Currency", "p.Mana",
            "p.LastSeenOnline", "p.ProfessionID", "prof.Name", "p.ClassID",
            "c.Name", "p.ClanName", "loc.LocationID", "loc.Name"
        ];
        const inequalities = ["=", "!=", ">", ">=", "<", "<=", "LIKE"];
        const from_clause = "Player p, PlayerLevel pl, Location loc, Profession prof, Class c";
        const join_clause = `(p.ProfessionID = prof.ProfessionID) AND 
                             (p.ClassID = c.ClassID) AND
                             (p.LocationID = loc.LocationID) AND 
                             (p.PlayerLevel = pl.PlayerLevel) AND
                             (p.ClassID = pl.ClassID)`;
        if (condList.length === 0) {
            const result = await connection.execute(
                `SELECT ${columns.join(", ")} FROM ${from_clause} WHERE ${join_clause}`
            );
            return result.rows;
        }

        const parsedList = parseCondList(condList);
        console.log(parsedList);
        for (const cond of parsedList) {
            if (!conds.includes(cond[0]) || !columns.includes(cond[1]) || !inequalities.includes(cond[2])) {
                console.log(cond);
                console.log(!conds.includes(cond[0]));
                console.log(!columns.includes(cond[1]));
                console.log(inequalities.includes(cond[2]));
                return -2;
            }
        }

        let where_clause = ``;
        let binds = {};
        for (let i = 0; i < parsedList.length; i++) {
            const curr_cond = parsedList[i];
            const key = `var${i}`;
            if (curr_cond[2] !== "LIKE") {
                if (i === 0) {
                    where_clause = `${where_clause}(${curr_cond[1]} ${curr_cond[2]} :${key})`;
                } else {
                    where_clause = `${where_clause} ${curr_cond[0]} (${curr_cond[1]} ${curr_cond[2]} :${key})`;
                }
            } else {
                if (i === 0) {
                    where_clause = `${where_clause}(LOWER(${curr_cond[1]}) ${curr_cond[2]} :${key})`;
                } else {
                    where_clause = `${where_clause} ${curr_cond[0]} (LOWER(${curr_cond[1]}) ${curr_cond[2]} :${key})`;
                }
            }
            
            binds[key] = curr_cond[3];
        }
        console.log(`(${where_clause}) AND ${join_clause}`);
        const result = await connection.execute(
            `SELECT ${columns.join(", ")} 
             FROM ${from_clause} 
             WHERE (${where_clause}) AND ${join_clause}`,
             binds
        );
        console.log(result.rows);
        return result.rows;
    }).catch(() => {
        return false;
    });
}


function parseCondList(condList) {
    for (const cond of condList) {
        if (cond[1] === "Player Level") {
            cond[1] = "p.PlayerLevel";
        } else if (cond[1] === "Currency") {
            cond[1] = "p.Currency";
        } else if (cond[1] === "Mana") {
            cond[1] = "p.Mana";
        } else if (cond[1] === "Profession ID") {
            cond[1] = "p.ProfessionID";
        } else if (cond[1] === "Class ID") {
            cond[1] = "p.ClassID";
        } else if (cond[1] === "Location ID") {
            cond[1] = "loc.LocationID";
        } else if (cond[1] === "Username") {
            cond[1] = "p.Username";
        } else if (cond[1] === "Profession Name") {
            cond[1] = "prof.Name";
        } else if (cond[1] === "Class Name") {
            cond[1] = "c.Name";
        } else if (cond[1] === "Clan Name") {
            cond[1] = "p.ClanName";
        } else if (cond[1] === "Location Name") {
            cond[1] = "ploc.Name";
        } else if (cond[1] === "Base Stats") {
            cond[1] = "pl.BaseStats";
        } else if (cond[1] === "Last Seen Online") {
            cond[1] = "p.LastSeenOnline";
        }

        if (cond[2] === "is equal to") {
            cond[2] = "=";
        } else if (cond[2] === "is not equal to") {
            cond[2] = "!=";
        } else if (cond[2] === "is greater than") {
            cond[2] = ">";
        } else if (cond[2] === "is greater than or equal to") {
            cond[2] = ">=";
        } else if (cond[2] === "is less than") {
            cond[2] = "<";
        } else if (cond[2] === "is less than or equal to") {
            cond[2] = "<=";
        } else if (cond[2] === "contains") {
            cond[2] = "LIKE";
        }

        if (cond[2] === "LIKE") {
            cond[3] = `%${cond[3].toLowerCase()}%`;
        }
    }
    return condList;
}

//aggregation with having query
async function agregationWithHaving(minPlayerCount) { // made smth - minPlayerCount
    return await withOracleDB(async (connection) => {
        
        const result = await connection.execute( // Anthony mentioned "Should also return attributes of the clan other than just the clan name" Dont know why but here it is
            `
            SELECT
                c.ClanName,
                c.MinLevelToJoin,
                c.ClanRank,   
                c.NumMembers,
                MIN(p.PlayerLevel) AS MinPlayerLevel,
                MAX(p.PlayerLevel) AS MaxPlayerLevel,
                ROUND(AVG(p.PlayerLevel), 2) AS AvgPlayerLevel
            FROM Clan c
            JOIN Player p ON c.ClanName = p.ClanName
            GROUP BY
                c.ClanName,
                c.MinLevelToJoin,
                c.ClanRank,
                c.NumMembers
            HAVING COUNT(p.Username) > :minPlayerCount
            `,
            { minPlayerCount: minPlayerCount }
        );

        return result.rows;
    }).catch(() => {
        return -1;
    });
}

module.exports = {
    testOracleConnection,
    fetchDemotableFromDb,
    fetchPlayerData,
    initiateDemotable, 
    reloadDB,
    insertDemotable, 
    updateNameDemotable, 
    countDemotable,
    agregationWithHaving,
    deleteItem,
    questProjection,
    selectPlayers,
    insertEnemy,
    fetchEnemyData,
    updateEnemy,
    getPlayerAbilities,
    getPlayersfriendsWithAllClanMembers
};