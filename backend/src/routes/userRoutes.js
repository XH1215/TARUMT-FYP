const express = require('express');
const { login, register, logout, verifyPassword, changePassword, getProfile, saveProfile, saveFeedback } = require('../controllers/userController');
const { search, showDetails } = require('../controllers/searchController');
const { createWalletandDID } = require('../credential/acapyRegister');
const { ViewCredential } = require('../credential/IssuedCredential')
const { storeCredentialAndHolders } = require('../credential/createCredAndStore');
const { Connection, handleConnection } = require('../credential/Connection');

const {
    saveCVProfile,
    saveCVSkill,
    deleteCVSkill,
    saveCVWork,
    deleteCVWork,
    saveCVEducation,
    deleteCVEducation,
    saveCVCertification,
    deleteCVCertification,
    updateCVCertification
} = require('../controllers/cvControllerSAINO'); // Import the controller functions


const { backdoorReset } = require('../controllers/backdoor');

const router = express.Router();

router.post('/backdoorReset', backdoorReset);


router.post('/login', login);
router.post('/register', register);
router.post('/logout', logout);


router.post('/search-talent', search);
router.post('/showDetails', showDetails);
router.post('/verifyPassword', verifyPassword);
router.post('/changePassword', changePassword);
router.post('/getProfile', getProfile);
router.post('/saveProfile', saveProfile);
router.post('/saveFeedback', saveFeedback);


router.post('/saveCVProfile', saveCVProfile);
router.post('/saveCVSkill', saveCVSkill);
router.post('/deleteCVSkill', deleteCVSkill);
router.post('/saveCVWork', saveCVWork);
router.post('/deleteCVWork', deleteCVWork);
router.post('/saveCVEducation', saveCVEducation);
router.post('/deleteCVEducation', deleteCVEducation);
router.post('/saveCVCertification', saveCVCertification);
router.post('/deleteCVCertification', deleteCVCertification);
router.post('/updateCVCertification', updateCVCertification);


router.post('/createWalletandDID', createWalletandDID);
router.post('/ViewCredential', ViewCredential);
router.post('/connection', Connection);
// Route to handle connection creation
router.post('/createCredential', async (req, res) => {
    try {
        const { user, holders, credential } = req.body;
        console.log(req.body);
        // Call the function to store holders and credential
        await storeCredentialAndHolders(user, holders, credential);

        res.status(201).json({
            message: 'Credential issued and holders linked successfully'
        });
    } catch (error) {
        console.error('Error:', error);
        res.status(500).json({
            message: 'Failed to issue credential and store holders',
            error: error.message
        });
    }
});
router.post('/connection', Connection);

module.exports = router;
