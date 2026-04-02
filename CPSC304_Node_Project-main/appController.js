const express = require('express');
const appService = require('./appService');

const router = express.Router();

// ----------------------------------------------------------
// API endpoints
// Modify or extend these routes based on your project's needs.
router.get('/check-db-connection', async (req, res) => {
    const isConnect = await appService.testOracleConnection();
    if (isConnect) {
        res.send('connected');
    } else {
        res.send('unable to connect');
    }
});

router.get('/demotable', async (req, res) => {
    const tableContent = await appService.fetchDemotableFromDb();
    res.json({data: tableContent});
});

router.get('/player-table', async (req, res) => {
    const playerContent = await appService.fetchPlayerData();
    res.json({data: playerContent});
});

router.get('/item-table', async (req, res) => {
    const tableContent = await appService.fetchItemData();
    res.json({data: tableContent});
});

router.post("/initiate-demotable", async (req, res) => {
    const initiateResult = await appService.initiateDemotable();
    if (initiateResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.post("/reload-db", async (req, res) => {
    const reloadResult = await appService.reloadDB();
    if (reloadResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.post("/delete-item", async (req, res) => {
    const { itemId } = req.body;
    const deleteResult = await appService.deleteItem(itemId);
    if (deleteResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.post("/quest-projection", async (req, res) => {
    const { order } = req.body;
    const projectionResult = await appService.questProjection(order);
    if (projectionResult === -1 || projectionResult === -2) {
        res.status(400).json({ success: false });
    } else if (projectionResult !== false) {
        res.json({ success: true, data: projectionResult });
    } else {
        res.status(500).json({ success: false });
    }
});

router.post("/select-players", async (req, res) => {
    const { condList } = req.body;
    const selectionResult = await appService.selectPlayers(condList);
    if (selectionResult === -1 || selectionResult === -2) {
        res.status(400).json({ success: false });
    } else if (selectionResult !== false) {
        res.json({ success: true, data: selectionResult });
    } else {
        res.status(500).json({ success: false });
    }
});

router.post("/agregation-with-having", async (req, res) => {
    const { minPlayerCount } = req.body;
    const agregationResult = await appService.agregationWithHaving(minPlayerCount);
    if (agregationResult !== -1) {
        res.json({ 
            success: true,
            data: agregationResult
        });
    } else {
        res.status(500).json({ 
            success: false,
            data: agregationResult
        });
    }
});

router.post("/insert-enemy", async (req, res) => {
    const { npcId, enemySpecies, expDropped, goldDropped, name, npcLevel, baseStats, locationId } = req.body;
    const insertResult = await appService.insertEnemy(npcId, enemySpecies, expDropped, goldDropped, name, npcLevel, baseStats, locationId);
    if (insertResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.post("/insert-demotable", async (req, res) => {
    const { id, name } = req.body;
    const insertResult = await appService.insertDemotable(id, name);
    if (insertResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.post("/update-name-demotable", async (req, res) => {
    const { oldName, newName } = req.body;
    const updateResult = await appService.updateNameDemotable(oldName, newName);
    if (updateResult) {
        res.json({ success: true });
    } else {
        res.status(500).json({ success: false });
    }
});

router.get('/count-demotable', async (req, res) => {
    const tableCount = await appService.countDemotable();
    if (tableCount >= 0) {
        res.json({ 
            success: true,  
            count: tableCount
        });
    } else {
        res.status(500).json({ 
            success: false, 
            count: tableCount
        });
    }
});

//for the update query
router.get('/enemy-table', async (req,res) => {
    const enemies = await appService.fetchEnemyData();
    res.json({data: enemies});
});

router.post('/update-enemy', async (req, res) => {
    const { npcId, name, npcLevel, baseStats, locationId, enemySpecies, expDropped, goldDropped } = req.body;
    const updateResult = await appService.updateEnemy(npcId, name, npcLevel, baseStats, locationId, enemySpecies, expDropped, goldDropped);
    if (updateResult) {
        res.json({success : true});
    } else {
        res.status(500).json({success: false});
    }
});

//for the join query
router.get('/player-abilities', async (req,res) => {
    const {username} = req.query;
    const result = await appService.getPlayerAbilities(username);
    res.json({data: result});
});

//for division
router.get('/friends-with-all-clan-members', async (req, res) => {
    const result = await appService.getPlayersfriendsWithAllClanMembers();
    res.json({ data: result });
});

router.get('/player-count-by-location', async (req, res) => {
    const counts = await appService.playerCountByLocation();
    res.json({success: true, data: counts});
});

router.get('/get-strong-npcs', async (req, res) => {
    const result = await appService.getStrongNPCs();
    res.json({success: true, data: result});
});

module.exports = router;