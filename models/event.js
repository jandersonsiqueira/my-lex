const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
    date: { type: Date, required: false },
    title: { type: String, required: false }
});

module.exports = mongoose.model('Event', eventSchema);
