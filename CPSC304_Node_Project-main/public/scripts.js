/*
 * These functions below are for various webpage functionalities. 
 * Each function serves to process data on the frontend:
 *      - Before sending requests to the backend.
 *      - After receiving responses from the backend.
 * 
 * To tailor them to your specific needs,
 * adjust or expand these functions to match both your 
 *   backend endpoints 
 * and 
 *   HTML structure.
 * 
 */


// This function checks the database connection and updates its status on the frontend.
async function checkDbConnection() {
    const statusElem = document.getElementById('dbStatus');
    const loadingGifElem = document.getElementById('loadingGif');

    const response = await fetch('/check-db-connection', {
        method: "GET"
    });

    // Hide the loading GIF once the response is received.
    loadingGifElem.style.display = 'none';
    // Display the statusElem's text in the placeholder.
    statusElem.style.display = 'inline';

    response.text()
    .then((text) => {
        statusElem.textContent = text;
    })
    .catch((error) => {
        statusElem.textContent = 'connection timed out';  // Adjust error handling if required.
    });
}

// Fetches data from the demotable and displays it.
async function fetchAndDisplayUsers() {
    const tableElement = document.getElementById('demotable');
    const tableBody = tableElement.querySelector('tbody');

    const response = await fetch('/demotable', {
        method: 'GET'
    });

    const responseData = await response.json();
    const demotableContent = responseData.data;

    // Always clear old, already fetched data before new fetching process.
    if (tableBody) {
        tableBody.innerHTML = '';
    }

    demotableContent.forEach(user => {
        const row = tableBody.insertRow();
        user.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}

// Fetches player data and displays it
async function fetchAndDisplayPlayers() {
    const tableElement = document.getElementById('playerTable');
    const tableBody = tableElement.querySelector('tbody');

    const response = await fetch('/player-table', {
        method: 'GET'
    });

    const responseData = await response.json();
    const playerContent = responseData.data;

    if (tableBody) {
        tableBody.innerHTML = '';
    }

    playerContent.forEach(user => {
        const row = tableBody.insertRow();
        user.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}

// This function resets or initializes the demotable.
async function resetDemotable() {
    const response = await fetch("/initiate-demotable", {
        method: 'POST'
    });
    const responseData = await response.json();

    if (responseData.success) {
        const messageElement = document.getElementById('resetResultMsg');
        messageElement.textContent = "demotable initiated successfully!";
        fetchTableData();
    } else {
        alert("Error initiating table!");
    }
}

// Drops, recreates, and reloads all tables in the database (not including the demotable).
async function reloadDB() {
    const button = document.getElementById('reloadDatabase');
    const messageElement = document.getElementById('reloadResultMsg');
    button.disabled = true;

    const response = await fetch("/reload-db", {
        method: 'POST'
    });
    const responseData = await response.json();

    if (responseData.success) {
        messageElement.textContent = "Database successfully reloaded!";
        fetchTableData();
    } else {
        alert("Error reloading database!");
    }
    button.disabled = false;
}

// deletes item 
async function deleteItem(event) {
    event.preventDefault();

    const itemIdVal = document.getElementById('deleteItemId').value;

    const response = await fetch('/delete-item', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            itemId: itemIdVal
        })
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('deleteItemResultMsg');

    if (responseData.success) {
        messageElement.textContent = "Item deleted";
    } else {
        messageElement.textContent = "Error while deleting the item";
    }
}

// 
async function agregationWithHaving(event) {
    event.preventDefault();

    const minPlayerCountVal = document.getElementById('minPlayerCount').value;

    const response = await fetch('/agregation-with-having', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            minPlayerCount: minPlayerCountVal
        })
    });

    const responseData = await response.json();
    const message = document.getElementById('agregationWithHavingResultMsg');

    const tableElement = document.getElementById('agregationWithHavingTable');
    const tableBody = tableElement.querySelector('tbody');

    // Always clear old, already fetched data before new fetching process.
    if (tableBody) {
        tableBody.innerHTML = '';
    }


    responseData.data.forEach(rowData => {
        const row = tableBody.insertRow();
        rowData.forEach((field, index) => {
            const cell = row.insertCell(index);
            cell.textContent = field;
        });
    });
}


async function insertEnemy(event) {
    event.preventDefault();

    const npcIdValue = document.getElementById('insertNpcId').value;
    const enemySpeciesValue = document.getElementById('insertEnemySpecies').value;
    const expDroppedValue = document.getElementById('insertExpDropped').value;
    const goldDroppedValue = document.getElementById('insertGoldDropped').value;
    const npcNameValue = document.getElementById('insertNpcName').value;
    const npcLevelValue = document.getElementById('insertNpcLevel').value;
    const baseStatsValue = document.getElementById('insertBaseStats').value;
    const locationIdValue = document.getElementById('insertLocationId').value;

    const response = await fetch('/insert-enemy', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            npcId: npcIdValue,
            enemySpecies: enemySpeciesValue,
            expDropped: expDroppedValue,
            goldDropped: goldDroppedValue,
            name: npcNameValue,
            npcLevel: npcLevelValue,
            baseStats: baseStatsValue,
            locationId: locationIdValue
        })
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('insertResultMsg');

   if (responseData.success) {
        messageElement.textContent = "Data inserted successfully!";
        fetchAndDisplayEnemies();
    } else {
        messageElement.textContent = "Error inserting data!";
    }
}

// Inserts new records into the demotable.
async function insertDemotable(event) {
    event.preventDefault();

    const idValue = document.getElementById('insertId').value;
    const nameValue = document.getElementById('insertName').value;

    const response = await fetch('/insert-demotable', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            id: idValue,
            name: nameValue
        })
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('insertResultMsg');

    if (responseData.success) {
        messageElement.textContent = "Data inserted successfully!";
        fetchTableData();
    } else {
        messageElement.textContent = "Error inserting data!";
    }
}

// Updates names in the demotable.
async function updateNameDemotable(event) {
    event.preventDefault();

    const oldNameValue = document.getElementById('updateOldName').value;
    const newNameValue = document.getElementById('updateNewName').value;

    const response = await fetch('/update-name-demotable', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            oldName: oldNameValue,
            newName: newNameValue
        })
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('updateNameResultMsg');

    if (responseData.success) {
        messageElement.textContent = "Name updated successfully!";
        fetchTableData();
    } else {
        messageElement.textContent = "Error updating name!";
    }
}

// Counts rows in the demotable.
// Modify the function accordingly if using different aggregate functions or procedures.
async function countDemotable() {
    const response = await fetch("/count-demotable", {
        method: 'GET'
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('countResultMsg');

    if (responseData.success) {
        const tupleCount = responseData.count;
        messageElement.textContent = `The number of tuples in demotable: ${tupleCount}`;
    } else {
        alert("Error in count demotable!");
    }
}

//for displaying the enemies table, UPDATE query
async function fetchAndDisplayEnemies() {
    const tableElement = document.getElementById('enemyTable');
    const tableBody = tableElement.querySelector('tbody');
    const response = await fetch('/enemy-table',{method: 'GET'});
    const responseData = await response.json();

    if (tableBody) tableBody.innerHTML = '';

    responseData.data.forEach(row => {
        const tableRow = tableBody.insertRow();
        row.forEach((field, index) => {
            const cell = tableRow.insertCell(index);
            cell.textContent = field;
        });
        tableRow.style.cursor = 'pointer';
        tableRow.addEventListener('click', () => {
            document.getElementById('updateNpcId').value = row[0];
            document.getElementById('updateEnemySpecies').value = row[2];
            document.getElementById('updateExpDropped').value = row[3];
            document.getElementById('updateGoldDropped').value = row[4];

        });
    });
    
}

async function updateEnemy(event) {
    event.preventDefault();

    const npcId = document.getElementById('updateNpcId').value;
    const enemySpecies = document.getElementById('updateEnemySpecies').value;
    const expDropped = document.getElementById('updateExpDropped').value;
    const goldDropped = document.getElementById('updateGoldDropped').value;

    const response = await fetch('/update-enemy', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({npcId, enemySpecies, expDropped, goldDropped})
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('updateEnemyResultMsg');

    if (responseData.success) {
        messageElement.textContent = "Enemy updated successfully!";
        fetchAndDisplayEnemies();
    } else {
        messageElement.textContent = "Error updating enemy!";
    }
}

//player abilities, JOIN query
async function getPlayerAbilities(event) {
    event.preventDefault();
    const username = document.getElementById('abilityUsername').value;
    const response = await fetch(`/player-abilities?username=${encodeURIComponent(username)}`, {
        method: 'GET'
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('playerAbilitiesResultMsg');
    const tableElement = document.getElementById('playerAbilitiesTable');
    const tableBody = tableElement.querySelector('tbody');

    if (tableBody) tableBody.innerHTML = '';

    if (responseData.data.length === 0) {
        messageElement.textContent = "No results found for that username.";
        return;
    }

    messageElement.textContent = '';
    responseData.data.forEach(row => {
        const tableRow = tableBody.insertRow();
        row.forEach((field, index) => {
            const cell = tableRow.insertCell(index);
            cell.textContent = field;
        });
    });
    
}

async function friendsWithAllClanMembers() {
    const response = await fetch('/friends-with-all-clan-members', {
        method:'GET'
    });

    const responseData = await response.json();
    const messageElement = document.getElementById('divisionResultMsg');
    const tableElement = document.getElementById('divisionTable');
    const tableBody = tableElement.querySelector('tbody');

    if (tableBody) tableBody.innerHTML = '';

    if (responseData.data.length === 0) {
        messageElement.textContent = "No players found.";
        return;
    }

    messageElement.textContent = '';
    responseData.data.forEach(row => {
        const tableRow = tableBody.insertRow();
        row.forEach((field, index) => {
            const cell = tableRow.insertCell(index);
            cell.textContent = field;
        });
    });
    
}

// ---------------------------------------------------------------
// Initializes the webpage functionalities.
// Add or remove event listeners based on the desired functionalities.
window.onload = function() {
    checkDbConnection();
    fetchTableData();
    fetchAndDisplayEnemies();
    document.getElementById("resetDemotable").addEventListener("click", resetDemotable);
    document.getElementById("reloadDatabase").addEventListener("click", reloadDB);
    document.getElementById("deleteItem").addEventListener("submit", deleteItem);
    document.getElementById("agregationWithHaving").addEventListener("submit", agregationWithHaving);
    document.getElementById("insertEnemy").addEventListener("submit", insertEnemy);
    document.getElementById("insertDemotable").addEventListener("submit", insertDemotable);
    // document.getElementById("updataNameDemotable").addEventListener("submit", updateNameDemotable);
    // document.getElementById("countDemotable").addEventListener("click", countDemotable);
    document.getElementById("updateEnemyForm").addEventListener("submit", updateEnemy);
    document.getElementById("playerAbilitiesForm").addEventListener("submit", getPlayerAbilities);
    document.getElementById("divisionQuery").addEventListener("click", friendsWithAllClanMembers);
    
};

// General function to refresh the displayed table data. 
// You can invoke this after any table-modifying operation to keep consistency.
function fetchTableData() {
    fetchAndDisplayUsers();
    fetchAndDisplayPlayers();
    fetchAndDisplayEnemies();
}
