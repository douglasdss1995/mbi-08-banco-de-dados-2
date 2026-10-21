# Guia rápido: enviar um arquivo ao repositório do grupo com o GitKraken

Aula 2 · para o primeiro commit do diagrama do tema

O repositório do grupo fica no **GitHub**, e o **GitKraken** é a ferramenta gráfica que usamos para trabalhar com ele.
Os repositórios do curso são **públicos**: qualquer pessoa pode ver o que está neles. Por isso, só coloque dados
fictícios, nunca senhas nem dados pessoais reais.

## Antes de começar

- Você tem a conta do **GitHub** e o **GitKraken** instalado (checklist da aula 1).
- Você foi adicionado como **colaborador** do repositório do grupo e aceitou o convite (o convite chega por e-mail e em
  https://github.com/notifications). Sem isso, o envio é recusado.
- O nome do repositório é `bd2-grupo-NN-tema` (por exemplo, `bd2-grupo-01-biblioteca`).

## Os 4 passos

### 1. Clonar (uma vez)

Clonar é baixar o repositório do GitHub para a sua máquina.

1. Abra o GitKraken e entre com a sua conta do GitHub.
2. No menu **File**, escolha **Clone Repo**.
3. Escolha a aba **GitHub.com**, selecione `bd2-grupo-NN-tema` e uma **pasta** para guardá-lo (por exemplo,
   `D:\bancodados`).
4. Clique em **Clone the Repo!**

### 2. Colocar os arquivos (diagrama)

1. Abra a pasta do repositório no Explorador de Arquivos.
2. Crie a pasta `diagrama` se ela não existir.
3. Copie para dentro dela o arquivo do ERD Concepts e a **imagem** exportada do diagrama (PNG ou PDF).

### 3. Commit

O commit é um "ponto salvo" com uma mensagem.

1. Volte ao GitKraken: os arquivos novos aparecem como alterações pendentes (**WIP**).
2. Clique em **Stage All Changes** (colocar todas as alterações na área de envio).
3. No campo de resumo, escreva uma mensagem curta e clara, por exemplo: `Adiciona primeira versão do diagrama`.
4. Clique em **Commit changes**.

### 4. Push

O push envia os seus commits para o GitHub.

1. Se outro integrante já enviou algo, clique em **Pull** antes, para trazer as alterações dele.
2. Clique em **Push**.
3. Confira no GitHub (`github.com`, no repositório do grupo): o arquivo deve aparecer lá.

## Combinados do grupo

- **Cada integrante faz o seu commit**, com o seu usuário. O histórico não vale nota, mas mostra quem fez cada parte.
- Mensagens de commit curtas e no imperativo: `Adiciona`, `Corrige`, `Remove`.
- Antes de começar a trabalhar, clique em **Pull**; antes de ir embora, em **Push**.
- Não envie senhas, dados pessoais reais nem arquivos enormes.

## Se der errado

| Problema | O que fazer |
|---|---|
| Erro de autenticação ao clonar ou enviar | Saia e entre de novo com a conta do GitHub, nas preferências do GitKraken |
| Mensagem de permissão negada (403) | Você ainda não é colaborador, ou não aceitou o convite. Peça a quem criou o repositório |
| O repositório do grupo não aparece na lista | Use a aba **URL** e cole o endereço do repositório |
| Conflito (duas pessoas mudaram o mesmo arquivo) | Chame o professor: resolvemos juntos na primeira vez |
| O GitKraken não abre ou não entra | O professor mostra o envio pelo site do GitHub (**Add file › Upload files**) |

## Ao terminar a aula

Esta é uma máquina do laboratório. **Saia da sua conta** do GitKraken (nas preferências) e do GitHub no navegador, para
a próxima pessoa não usar a sua conta.
