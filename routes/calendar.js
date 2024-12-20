const express = require('express');
const router = express.Router();
const Event = require("../models/event");

// Rota para obter todos os eventos
router.get('/', async (req, res) => {
    const events = await Event.find();
    return res.send(events);
});

// Rota para obter eventos por data (com validação)
router.get('/by-date/:year/:month', async (req, res) => {
    const year = parseInt(req.params.year);
    const month = parseInt(req.params.month);

    if (isNaN(year) || isNaN(month) || year <= 0 || month <= 0 || month > 12) {
        return res.status(400).send({ error: 'Parâmetros de data inválidos' });
    }

    const start = new Date(year, month - 1, 1).toISOString();
    const end = new Date(year, month, 1).toISOString();

    const events = await Event.find({
        date: {
            $gte: start,
            $lt: end
        }
    });

    return res.send(events);
});

// Rota para obter um evento por ID
router.get('/:id', async (req, res) => {
    const event = await Event.findById(req.params.id);
    if (!event) {
        return res.status(404).send({ error: 'Evento não encontrado' });
    }
    return res.send(event);
});

// Rota para criar um novo evento
router.post('/', async (req, res) => {
    const { date, title } = req.body;
    const event = new Event({ date, title });
    await event.save();
    return res.send(event);
});

// Rota para atualizar um evento por ID
router.put('/:id', async (req, res) => {
    const { date, title } = req.body;
    const event = await Event.findByIdAndUpdate(req.params.id, { date, title }, { new: true });
    if (!event) {
        return res.status(404).send({ error: 'Evento não encontrado' });
    }
    return res.send(event);
});

// Rota para deletar um evento por ID
router.delete('/:id', async (req, res) => {
    const event = await Event.findByIdAndDelete(req.params.id);
    if (!event) {
        return res.status(404).send({ error: 'Evento não encontrado' });
    }
    return res.send(event);
});

module.exports = router;
