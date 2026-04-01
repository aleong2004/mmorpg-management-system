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
        const result = await connection.execute('SELECT * FROM Player');
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
// STUFF

// Insert query
//async function insertEnemy(enemyData) { TODO: this shit got hands ;-;

//delete query
async function deleteItem() {
    return await withOracleDB(async (connection) => {
        const result = await connection.execute(
            `DELETE FROM Item WHERE ItemID =: itemId`,
            [itemId],
            { autoCommit: true }
        );

        return result.rowsAffected && result.rowsAffected > 0;
    }).catch(() => {
        return -1;
    });
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
                ROUND(AVG(p.PlayerLevel), 2) AS AvgPlayerLevel,
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
    deleteItem
};