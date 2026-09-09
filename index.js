import express from 'express';
const app = express();
const port = 3001;
import cors from 'cors';
//import { OPCUAClient, AttributeIds } from "node-opcua";

function randint(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

app.use(cors())
app.use(express.json())
app.use(express.urlencoded({extended: true}))

import mysql from 'mysql2/promise';

const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  database: 'wssc2',
  port: 8086,
  password: 'root',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

const idsUsados = [];

async function existeNaTabela(tabela,id) {
  const [rows] = await pool.query(`SELECT 1 FROM ${tabela} WHERE id = ? LIMIT 1`,[id]);
  return rows.length > 0;
}

function geraIdUnico(idsUsados, min = 1, max = 9999) {
    let randint;
    do {
        randint = Math.floor(Math.random() * (max - min + 1)) + min;
    } while (idsUsados.includes(randint));
    idsUsados.push(randint); 
    return randint;
}


app.get('/', (req,res) => {
  res.send('Gestor de Estoque - Planta Smart4.0 - SENAI Norte Joinville')
})

// Cores

app.get('/cores', async (req, res) => {
  try {
    const [results] = await pool.query('SELECT * FROM wssc2.cores_lams');
    
    res.json(results); 

  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});

app.post('/cores', async (req, res) => {
  console.log(req.body)
  try {
    const {nome} = req.body

    const [results] = await pool.execute(
      'INSERT INTO cores_lams(nome) VALUES (?)',
    [nome]);

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.delete('/cores/:id', async (req, res) => {
  try{
    const {id} = req.params

    const [results] = await pool.execute(
      'DELETE FROM cores_lams WHERE id = ?',
      [id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Cor não encontrada'
      })
    }

    res.json(results);

  } catch (err) {
    console.error(err);
    res.status(500).json({error: 'Query do banco de dados falhou:', details: err.message})
  }
});


app.put('/cores/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { nome } = req.body;

    const [results] = await pool.execute(
      'UPDATE cores_lams SET nome = ? WHERE id = ?',
      [nome, id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Cor não encontrada'
      })
    }

    res.json({ message: 'Cor atualizada com sucesso', results });
  } catch (err) {
    res.status(500).json({ error: 'Query do banco de dados falhou', details: err.message });
  }
});

// Armazéns

app.get('/armazens', async (req, res) => {
  try {
    const [results] = await pool.query('SELECT * FROM wssc2.stg'); 

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.post('/armazens', async (req, res) => {
  console.log(req.body)
  try {
    const {nome, capacidade} = req.body

    const [results] = await pool.execute(
      'INSERT INTO stg(nome, capacidade) VALUES (?,?)',
    [nome, capacidade]);

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.delete('/armazens/:id', async (req, res) => {
  try{
    const {id} = req.params

    const [results] = await pool.execute(
      'DELETE FROM stg WHERE id = ?',
      [id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Armazém não encontrado'
      })
    }

    res.json(results);

  } catch (err) {
    console.error(err);
    res.status(500).json({error: 'Query do banco de dados falhou:', details: err.message})
  }
});


app.put('/armazens/:id', async (req,res) => {
  try{
    const { id } = req.params
    const {nome, capacidade} = req.body

    const [results] = await pool.execute(
      'UPDATE stg SET nome = ?, capacidade = ? WHERE id = ?',
      [nome, capacidade, id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Armazém não encontrado'
      })
    }
    res.json({ message: 'Armazém atualizado com sucesso', results });
  } catch (err) {
    console.error(err);
    res.status(500).json({error: 'Query do banco de dados falhou:', details: err.message})
  }
});

// Buffers

app.get('/buffers', async (req, res) => {
  try {
    const [results] = await pool.query('SELECT * FROM wssc2.buffers');

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.post('/buffers', async (req, res) => {
  console.log(req.body)
  try {
    const {nome, capacidade} = req.body

    const [results] = await pool.execute(
      'INSERT INTO buffers(nome, capacidade) VALUES (?,?)',
    [nome, capacidade]);

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.delete('/buffers/:id', async (req, res) => {
  try{
    const {id} = req.params

    const [results] = await pool.execute(
      'DELETE FROM buffers WHERE id = ?',
      [id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Buffer não encontrado'
      })
    }

    res.json(results);

  } catch (err) {
    console.error(err);
    res.status(500).json({error: 'Query do banco de dados falhou:', details: err.message})
  }
});


app.put('/buffers/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { capacidade, nome } = req.body;

    const [results] = await pool.execute(
      'UPDATE buffers SET nome = ?, capacidade = ? WHERE id = ?',
      [nome, capacidade, id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Buffer não encontrado'
      })
    }

    res.json({ message: 'Buffer atualizado com sucesso', results });
  } catch (err) {
    res.status(500).json({ error: 'Query do banco de dados falhou', details: err.message });
  }
});

// Blocos

app.get('/blocos', async (req, res) => {
  try {
    const [results] = await pool.query('SELECT * FROM wssc2.blocos');
  
    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.get('/blocos/:storageId', async (req, res) => {
  try {
    const {storageId} = req.params

    if (!(await existeNaTabela('stg',storageId))) {
      return res.status(404).json({error: 'Armazém não encontrado!'})
    }
    const [results] = await pool.query('SELECT * FROM wssc2.blocos WHERE storageId = ?',
      [storageId]);

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.post('/blocos', async (req, res) => {
  console.log(req.body)
  try {
    const {position, color, storageId} = req.body
    const [results] = await pool.execute(
      'INSERT INTO blocos(position, color, storageId) VALUES (?,?,?)',
    [position, color, storageId]);

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.delete('/blocos/:id', async (req, res) => {
  try{
    const {id} = req.params

    const [results] = await pool.execute(
      'DELETE FROM blocos WHERE id = ?',
      [id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Bloco não encontrado'
      })
    }

    res.json(results);

  } catch (err) {
    console.error(err);
    res.status(500).json({error: 'Query do banco de dados falhou:', details: err.message})
  }
});


app.put('/blocos/:id', async (req,res) => {
  try{
    const { id } = req.params ;
    const {position, color, storageId} = req.body

    const [results] = await pool.execute(
      'UPDATE blocos SET position = ?, color = ?, storageId = ? WHERE id = ?',
      [position ?? null, color, storageId ?? null, id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Bloco não encontrado'
      })
    }

    res.json({ message: 'Bloco atualizado com sucesso', results });
  } catch (err) {
    console.error(err);
    res.status(500).json({error: 'Query do banco de dados falhou:', details: err.message})
  }
});

// Lâminas

app.get('/laminas', async (req, res) => {
  try {
    const [results] = await pool.query('SELECT * FROM wssc2.lams');
  

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.get('/laminas/andares/:andarId', async (req, res) => {
  try {
    const { andarId } = req.params;
    if (!(await existeNaTabela('andares',andarId))) {
      return res.status(404).json({error: "Andar não encontrado!"})
    }
    const [results] = await pool.query(
      'SELECT * FROM lams WHERE andarId = ? ORDER BY posicaoLam',
      [andarId]
    );

    res.json(results);

  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: 'Query do banco de dados falhou:',
      details: err.message
    });
  }
});


app.get('/laminas/buffers/:bufferId', async (req, res) => {
  try {
    const {bufferId} = req.params
    if (!(await existeNaTabela('buffers',bufferId))) {
      return res.status(404).json({error: "Buffer não encontrado!"})
    }
    const [results] = await pool.query('SELECT * FROM wssc2.lams WHERE bufferId = ?',
      [bufferId]);

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.post('/laminas', async (req, res) => {
  try {
    const { color, bufferId, posicaoLam, andarId } = req.body;
    const [results] = await pool.execute(
      'INSERT INTO lams (color, bufferId, posicaoLam, andarId) VALUES (?, ?, ?, ?)',
      [color, bufferId ?? null, posicaoLam ?? null, andarId ?? null]
    );
    res.json({ id: results.insertId, color, bufferId, posicaoLam, andarId });
  } catch (err) {
    res.status(500).json({ error: 'Query do banco de dados falhou: ', details: err.message });
  }
});


app.delete('/laminas/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const [results] = await pool.execute('DELETE FROM lams WHERE id = ?', [id]);

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Lâmina não encontrada'
      })
    }

    res.json({ message: 'Lâmina removida com sucesso', results });

  } catch (err) {
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.put('/laminas/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { color, bufferId, andarId, posicaoLam } = req.body;

    const [results] = await pool.execute(
      'UPDATE lams SET color = ?, bufferId = ?, andarId = ?, posicaoLam = ? WHERE id = ?',
      [color, bufferId ?? null, andarId ?? null, posicaoLam ?? null, id]
    );

      if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Lâmina não encontrada'
      })
    }

    res.json({ message: 'Lâmina atualizada com sucesso', results });
  } catch (err) {
    res.status(500).json({ error: 'Query do banco de dados falhou', details: err.message });
  }
});

// OPs

app.get('/ops', async (req, res) => {
  try {
    const [results] = await pool.query('SELECT * FROM wssc2.ops');

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.post('/ops', async (req, res) => {
  console.log(req.body);
  let connection = await pool.getConnection();
  await connection.beginTransaction();
  const { storageId, position } = req.body;
  try {
    
    const [tampas] = await connection.execute(
      'SELECT MIN(id) AS targetId FROM tampas WHERE bufferId = 7 FOR UPDATE'
    );

    if(!tampas[0].targetId) {
      throw new Error('Nenhuma tampa disponível.')
    }

    const tampaId = tampas[0].targetId;

    const opId = `OP${geraIdUnico(idsUsados)}`;

    const [results] = await connection.execute(
      'INSERT INTO ops (storageId, tampaId, id, position) VALUES (?, ?, ?, ?)',
      [storageId, tampaId, opId, position]
    );

    const [tampaResult] = await connection.execute(
      'UPDATE tampas SET bufferId = null WHERE id = ?', [tampaId]
    );

    await connection.commit();
    res.json({
      tampa: tampaResult,
      insere: results
    });

  } catch (err) {
    if (connection) await connection.rollback();
    
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });

  } finally {
    if (connection) connection.release();
  }
});


app.delete('/ops/:id', async (req, res) => {
  try{
    const {id} = req.params

    const [results] = await pool.execute(
      'DELETE FROM ops WHERE id = ?',
      [id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'OP não encontrada'
      })
    }

    res.json(results);
    
  } catch (err) {
    console.error(err);
    res.status(500).json({error: 'Query do banco de dados falhou:', details: err.message})
  }
});


app.patch('/ops/:id', async (req, res) => {
  const { id } = req.params;
  const {storageId, position} = req.body

  try{
    const [results] = await pool.execute(
      'UPDATE ops SET storageId = ?, position = ? WHERE id = ?',
      [storageId, position, id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'OP não encontrada'
      });
    }

    res.json({
      message: 'OP atualizada com sucesso',
      results
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: 'Query do banco de dados falhou',
      details: err.message
    });
  }
});

// Tampas

app.get('/tampas', async (req, res) => {
  try {
    const [results] = await pool.query('SELECT * FROM wssc2.tampas');
    
    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.post('/tampas', async (req, res) => {
  console.log(req.body)
  try {
    const {bufferId} = req.body
    const [results] = await pool.execute(
      'INSERT INTO tampas(bufferId) VALUES (?)',
    [bufferId]);

    res.json(results); 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.delete('/tampas/:id', async (req, res) => {
  try{
    const {id} = req.params

    const [results] = await pool.execute(
      'DELETE FROM tampas WHERE id = ?',
      [id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Tampa não encontrada'
      })
    }

    res.json(results);

  } catch (err) {
    console.error(err);
    res.status(500).json({error: 'Query do banco de dados falhou:', details: err.message})
  }
});


app.put('/tampas/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { bufferId } = req.body;

    const [results] = await pool.execute(
      'UPDATE tampas SET bufferId = ? WHERE id = ?',
      [bufferId, id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Tampa não encontrada'
      })
    }

    res.json({ message: 'Tampa atualizada com sucesso', results });
  } catch (err) {
    res.status(500).json({ error: 'Query do banco de dados falhou', details: err.message });
  }
});

// Andares

app.get('/andares', async (req, res) => {
  try {
    const [andares] = await pool.query(`
      SELECT 
        a.id AS andarId,
        a.bloco,
        a.productionOrder AS op,
        a.posicaoAndar,
        GROUP_CONCAT(l.id) AS laminasIds
      FROM andares a
      LEFT JOIN lams l ON l.andarId = a.id
      GROUP BY a.id
      ORDER BY a.productionOrder, a.posicaoAndar ASC
    `);
    const response = andares.map(andar => ({
      ...andar,
      laminasIds: andar.laminasIds ? andar.laminasIds.split(',').map(Number) : []
    }));

    res.json(response);
  } catch (err) {
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });
  }
});


app.get('/andares/:opId', async (req, res) => {
  try {
    const { opId } = req.params;
    if (!(await existeNaTabela('ops',opId))) {
      return res.status(404).json({error: "OP não encontrada!"})
    }
    const [results] = await pool.query(
      'SELECT * FROM andares WHERE productionOrder = ? ORDER BY posicaoAndar',
      [opId]
    );

    res.json(results);

  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: 'Query do banco de dados falhou:',
      details: err.message
    });
  }
});


app.post('/andares', async (req, res) => {
  console.log(req.body)
  let connection = await pool.getConnection();
  await connection.beginTransaction();
  const {bloco, productionOrder, posicaoAndar} = req.body
  try {
    
    const [results] = await connection.execute(
      'INSERT INTO andares (bloco, productionOrder, posicaoAndar) VALUES (?,?,?)',
    [bloco, productionOrder, posicaoAndar]
    );

    const [blocoResult] = await connection.execute(
      'UPDATE blocos SET storageId = null WHERE id = ?',
      [bloco]
    );

    await connection.commit();
    res.json({
      bloco: blocoResult,
      insere: results
    });

  } catch (err) {
    if (connection) await connection.rollback();
    
    console.error(err);
    res.status(500).json({ error: 'Query do banco de dados falhou:', details: err.message });

  } finally {
    if (connection) connection.release();
  }
});


app.delete('/andares/:id', async (req, res) => {
  try{
    const {id} = req.params

    const [results] = await pool.execute(
      'DELETE FROM andares WHERE id = ?',
      [id]
    );

    if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Andar não encontrado'
      })
    }

    res.json(results);

  } catch (err) {
    console.error(err);
    res.status(500).json({error: 'Query do banco de dados falhou:', details: err.message})
  }
});


app.put('/andares/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { bloco, productionOrder, posicaoAndar } = req.body;

    const [results] = await pool.execute(
      'UPDATE andares SET bloco = ?, productionOrder = ?, posicaoAndar = ? WHERE id = ?',
      [bloco, productionOrder ?? null, posicaoAndar, id]
    );

      if(results.affectedRows === 0) {
      return res.status(404).json({
        error: 'Andar não encontrado'
      })
    }


    res.json({ message: 'Andar atualizado com sucesso', results });
  } catch (err) {
    res.status(500).json({ error: 'Query do banco de dados falhou', details: err.message });
  }
});

app.listen(port, () => {
  console.log(`O aplicativo está rodando na porta ${port}`)
});