# Gestor de Estoque — Planta Smart 4.0

API REST em **Node.js + Express** para controle do estoque da célula da Planta Smart 4.0 (SENAI Norte Joinville). O sistema gerencia o ciclo de montagem de Ordens de Produção (OPs), compostas por blocos, andares, lâminas e tampas, além dos armazéns posicionais e buffers usados para armazenar esses itens.

## Sumário

- [Modelo de domínio](#modelo-de-domínio)
- [Stack e dependências](#stack-e-dependências)
- [Configuração e execução](#configuração-e-execução)
- [Testando com Postman / Insomnia](#testando-com-postman--insomnia)
- [Padrão de respostas e erros](#padrão-de-respostas-e-erros)
- [Referência das rotas](#referência-das-rotas)
  - [Cores](#cores)
  - [Armazéns](#armazéns)
  - [Buffers](#buffers)
  - [Blocos](#blocos)
  - [Lâminas](#lâminas)
  - [OPs (Ordens de Produção)](#ops-ordens-de-produção)
  - [Tampas](#tampas)
  - [Andares](#andares)
- [Regras de negócio importantes](#regras-de-negócio-importantes)

---

## Modelo de domínio

| Entidade | Descrição |
|---|---|
| **Armazém** (`/armazens`, tabela `stg`) | Local posicional (com posições numeradas) onde ficam guardados **blocos** e **OPs**. |
| **Buffer** (`/buffers`, tabela `buffers`) | Local **não posicional**. Existem buffers de fila (FIFO) para tampas e buffers de pilha (LIFO/FILO) para lâminas — no total 6 buffers de lâminas (um por cor) + 1 buffer de tampas. |
| **Bloco** (`/blocos`, tabela `blocos`) | Matéria-prima base. Fica disponível em um armazém até ser usado para montar um andar. |
| **Lâmina** (`/laminas`, tabela `lams`) | Matéria-prima que é encaixada sobre um bloco para compor um andar. Pode estar em um buffer (aguardando uso) ou já vinculada a um andar. |
| **Andar** (`/andares`, tabela `andares`) | 1 bloco + de 0 a 3 lâminas. É a unidade que compõe uma OP. |
| **OP — Ordem de Produção** (`/ops`, tabela `ops`) | O pedido em si. Possui de 1 a 3 andares e **obrigatoriamente** uma tampa. Pode ser posicionada em um armazém. |
| **Tampa** (`/tampas`, tabela `tampas`) | Toda OP tem uma. É retirada do buffer de tampas (fila) e colocada no topo do andar mais alto da OP. |
| **Cor** (`/cores`, tabela `cores_lams`) | Paleta de cores disponíveis para as lâminas. |

### Relacionamento entre as tabelas

```
armazém (stg) ──< bloco (blocos)
armazém (stg) ──< OP (ops)
buffer (buffers) ──< tampa (tampas)
buffer (buffers) ──< lâmina (lams)
cor (cores_lams) ──< lâmina (lams)
bloco (blocos) ──1:1── andar (andares)
OP (ops) ──< andar (andares)
andar (andares) ──< lâmina (lams)   [0 a 3 lâminas]
OP (ops) ──1:1── tampa (tampas)
```

---

## Stack e dependências

- **Node.js** (ES Modules — `"type": "module"` no `package.json`)
- **Express** — framework HTTP
- **mysql2/promise** — driver MySQL com suporte a `async/await` e transações
- **cors** — liberação de requisições cross-origin

Banco de dados: **MySQL/MariaDB**, schema `wssc2` (scripts de criação em `DumpWssc2 (1).sql`, `procedure_1_wssc2.sql` e `triggers_1_wssc2.sql`).

## Configuração e execução

>  Atualmente a conexão com o banco está **hardcoded** em `index.js` (host, usuário, senha e porta). Ao subir o projeto, ajuste esses valores conforme o seu ambiente antes de rodar (idealmente migrando para variáveis de ambiente com `dotenv`).

```js
const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',
  database: 'wssc2',
  port: 8086,
  password: 'root',
  ...
});
```

Passos:

```bash
# 1. Instalar dependências
npm install

# 2. Subir/restaurar o banco wssc2 usando o dump do repositório
mysql -u root -p < "DumpWssc2 (1).sql"

# 3. Rodar a API
npm run dev
```

A API sobe em `http://localhost:3001`.

## Testando com Postman / Insomnia

1. **Base URL**: crie uma variável de ambiente (ex: `baseUrl = http://localhost:3001`) e monte as requisições como `{{baseUrl}}/blocos`, `{{baseUrl}}/ops`, etc.
2. **Headers**: para todo `POST`, `PUT` ou `PATCH`, defina `Content-Type: application/json`. A API já usa `express.json()`, então basta enviar o body no formato **JSON** (aba *Body → raw → JSON* no Postman/Insomnia).
3. **Sem autenticação**: a API não exige token/API key — todas as rotas são públicas.
4. **Ordem sugerida de testes** (respeitando as dependências entre tabelas):
   1. `POST /cores` e `POST /armazens` (não dependem de nada);
   2. `POST /blocos` (depende de um `storageId` de armazém existente);
   3. `POST /buffers` e `POST /tampas` (tampas dependem de um `bufferId`);
   4. `POST /laminas` (depende de `color`, e opcionalmente de `bufferId`/`andarId`);
   5. `POST /andares` (depende de um `bloco` existente e, se for vincular a uma OP, de uma `productionOrder` já criada);
   6. `POST /ops` (depende de haver ao menos uma tampa livre no buffer de tampas, id `7`, e opcionalmente de um `storageId`).
5. Para conferir o estado de uma OP montada, combine `GET /andares/:opId` com `GET /laminas/andares/:andarId` para ver bloco + lâminas de cada andar.
6. Dica: crie uma **Collection** no Postman/Insomnia com uma pasta por recurso (Cores, Armazéns, Buffers, Blocos, Lâminas, OPs, Tampas, Andares), replicando os títulos deste README.

## Padrão de respostas e erros

- Sucesso em `GET`: retorna o array de registros (ou objeto único) em JSON.
- Sucesso em `POST`: retorna o `ResultSetHeader` do `mysql2` (contém `insertId`, `affectedRows`, etc.) — na rota de lâminas, retorna também os dados enviados.
- Sucesso em `PUT`/`PATCH`: retorna `{ message: "... atualizado com sucesso", results }`.
- **404**: quando o `id` informado (ou uma dependência, como `storageId`/`andarId`/`opId`/`bufferId`) não existe. Formato: `{ "error": "<mensagem>" }`.
- **500**: falha de banco de dados. Formato: `{ "error": "Query do banco de dados falhou", "details": "<mensagem do erro>" }`.

---

## Referência das rotas

### Cores

Paleta de cores disponíveis para as lâminas (tabela `cores_lams`).

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/cores` | Lista todas as cores cadastradas. |
| `POST` | `/cores` | Cria uma nova cor. |
| `PUT` | `/cores/:id` | Atualiza o nome de uma cor existente. |
| `DELETE` | `/cores/:id` | Remove uma cor. |

**Body — `POST /cores` e `PUT /cores/:id`**
```json
{
  "nome": "Vermelha"
}
```

---

### Armazéns

Locais **posicionais** onde ficam blocos e OPs (tabela `stg`).

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/armazens` | Lista todos os armazéns. |
| `POST` | `/armazens` | Cria um novo armazém. |
| `PUT` | `/armazens/:id` | Atualiza nome/capacidade de um armazém. |
| `DELETE` | `/armazens/:id` | Remove um armazém. |

**Body — `POST /armazens` e `PUT /armazens/:id`**
```json
{
  "nome": "Estoque",
  "capacidade": 28
}
```

---

### Buffers

Locais **não posicionais**: 6 buffers de lâminas (um por cor, comportamento de pilha/LIFO) e 1 buffer de tampas (fila/FIFO) — tabela `buffers`.

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/buffers` | Lista todos os buffers. |
| `POST` | `/buffers` | Cria um novo buffer. |
| `PUT` | `/buffers/:id` | Atualiza nome/capacidade de um buffer. |
| `DELETE` | `/buffers/:id` | Remove um buffer. |

**Body — `POST /buffers` e `PUT /buffers/:id`**
```json
{
  "nome": "Laminas_red",
  "capacidade": 18
}
```

---

### Blocos

Matéria-prima base, disponível em um armazém até ser usada para montar um andar (tabela `blocos`).

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/blocos` | Lista todos os blocos. |
| `GET` | `/blocos/:storageId` | Lista os blocos de um armazém específico. Retorna `404` se o armazém não existir. |
| `POST` | `/blocos` | Cria um novo bloco. |
| `PUT` | `/blocos/:id` | Atualiza posição, cor ou armazém de um bloco. |
| `DELETE` | `/blocos/:id` | Remove um bloco. |

**Body — `POST /blocos` e `PUT /blocos/:id`**
```json
{
  "position": 1,
  "color": 2,
  "storageId": 1
}
```
---

### Lâminas

Matéria-prima encaixada sobre os blocos para compor os andares (tabela `lams`).

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/laminas` | Lista todas as lâminas. |
| `GET` | `/laminas/andares/:andarId` | Lista as lâminas vinculadas a um andar, ordenadas por `posicaoLam`. Retorna `404` se o andar não existir. |
| `GET` | `/laminas/buffers/:bufferId` | Lista as lâminas que estão dentro de um buffer específico. Retorna `404` se o buffer não existir. |
| `POST` | `/laminas` | Cria uma nova lâmina. |
| `PUT` | `/laminas/:id` | Atualiza cor, buffer, andar ou posição de uma lâmina. |
| `DELETE` | `/laminas/:id` | Remove uma lâmina. |

**Body — `POST /laminas` e `PUT /laminas/:id`**
```json
{
  "color": 3,
  "bufferId": 3,
  "posicaoLam": 1,
  "andarId": null
}
```
> Uma lâmina normalmente está **ou** em um `bufferId` (aguardando uso) **ou** vinculada a um `andarId` (já montada) — os dois podem ser `null`/preenchidos conforme o estágio da lâmina.

---

### OPs (Ordens de Produção)

O pedido em si: 1 a 3 andares + 1 tampa obrigatória, podendo estar posicionada em um armazém (tabela `ops`).

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/ops` | Lista todas as OPs. |
| `POST` | `/ops` | Cria uma nova OP. Gera o `id` automaticamente (`OP` + número aleatório) e **retira automaticamente a tampa mais antiga disponível** do buffer de tampas (`bufferId = 7`), vinculando-a à OP. |
| `PATCH` | `/ops/:id` | Atualiza armazém/posição de uma OP. |
| `DELETE` | `/ops/:id` | Remove uma OP. |

**Body — `POST /ops`**
```json
{
  "storageId": 1,
  "position": 1
}
```
> Não é necessário enviar `id` nem `tampaId`: o `id` da OP é gerado pelo servidor (`OPxxxx`) e a tampa é escolhida automaticamente pela API a partir da fila de tampas disponíveis. A rota retorna erro `500` com a mensagem `"Nenhuma tampa disponível."` se não houver tampa livre no buffer.

**Body — `PATCH /ops/:id`**
```json
{
  "storageId": 2,
  "position": 3
}
```

---

### Tampas

Peça obrigatória de toda OP, retirada do buffer de tampas (fila) e colocada no topo do andar mais alto (tabela `tampas`).

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/tampas` | Lista todas as tampas. |
| `POST` | `/tampas` | Cria uma nova tampa, associada a um buffer. |
| `PUT` | `/tampas/:id` | Atualiza o buffer de uma tampa. |
| `DELETE` | `/tampas/:id` | Remove uma tampa. |

**Body — `POST /tampas` e `PUT /tampas/:id`**
```json
{
  "bufferId": 7
}
```
> `bufferId` deve apontar para o buffer de tampas (no dump de dados atual, `id = 7`). Quando uma tampa é consumida por uma OP (via `POST /ops`), seu `bufferId` é automaticamente definido como `null`.

---

### Andares

1 bloco + de 0 a 3 lâminas; compõem uma OP (tabela `andares`).

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/andares` | Lista todos os andares, já trazendo o array `laminasIds` com as lâminas vinculadas a cada um (via `GROUP_CONCAT`). |
| `GET` | `/andares/:opId` | Lista os andares de uma OP específica, ordenados por `posicaoAndar`. Retorna `404` se a OP não existir. |
| `POST` | `/andares` | Cria um novo andar a partir de um bloco. Ao criar, **remove automaticamente o bloco do seu armazém** (`storageId` do bloco vira `null`, pois ele passou a fazer parte do andar). |
| `PUT` | `/andares/:id` | Atualiza bloco, OP vinculada ou posição de um andar. |
| `DELETE` | `/andares/:id` | Remove um andar. |

**Body — `POST /andares` e `PUT /andares/:id`**
```json
{
  "bloco": 1,
  "productionOrder": "OP4821",
  "posicaoAndar": 1
}
```
> `bloco` é o `id` do bloco que originará o andar (relação 1 para 1 — cada bloco só pode virar um andar). `productionOrder` é o `id` da OP dona do andar (pode ser `null` se o andar ainda não estiver vinculado a nenhuma OP). `posicaoAndar` indica a posição do andar dentro da OP (1, 2 ou 3).

---

## Regras de negócio importantes

- **Tampas são obrigatórias e automáticas**: ao criar uma OP (`POST /ops`), a API busca a tampa mais antiga disponível no buffer de tampas (fila, `bufferId = 7`) e a associa à OP dentro de uma transação — se não houver tampa livre, a criação falha.
- **Bloco sai do armazém ao virar andar**: ao criar um andar (`POST /andares`) a partir de um bloco, o bloco tem seu `storageId` zerado automaticamente, refletindo que ele deixou o armazém posicional para compor o andar.
- **Buffers de lâminas são de pilha (LIFO)** e o **buffer de tampas é de fila (FIFO)** — essa lógica de ordem de retirada está implementada apenas para tampas no momento (`SELECT MIN(id) ... FOR UPDATE`); ao consumir lâminas de um buffer via aplicação cliente, respeite o mesmo princípio (retirar a última lâmina inserida em cada buffer de cor).
- **IDs de OP são gerados no servidor**: o formato é `OP` + número aleatório entre 1 e 9999 (não repetido em memória durante a execução do processo).
- Todas as rotas de exclusão (`DELETE`) e atualização (`PUT`/`PATCH`) retornam `404` quando o `id` informado não é encontrado — trate isso no cliente antes de assumir sucesso.
