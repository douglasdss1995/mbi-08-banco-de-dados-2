# Checklist de ferramentas — Banco de Dados 2

Antes de começar, confira o que você já tem. O que estiver faltando, **baixe e instale** (na aula, ou em casa).
Marque com `x` o que estiver funcionando.

Os links de download das ferramentas estão reunidos no **Google Classroom** da turma (tópico de ferramentas).

## Obrigatórias

- [ ] **PostgreSQL** (versão 17 ou superior), com a ferramenta de linha de comando (`psql`).
  Site oficial: https://www.postgresql.org/download
  Anote a **senha** que você definir para o usuário `postgres`. Porta padrão: 5432.
- [ ] **Cliente de banco de dados: você escolhe um.**
  - **DBeaver Community** (gratuito). Site oficial: https://dbeaver.io/download
  - **DataGrip** (o mesmo que foi usado em Banco de Dados 1). Precisa de licença: a licença deve estar instalada
    nas máquinas do laboratório. Se não estiver, avise o professor, que solicita à TI.

  Anote qual você escolheu. O professor demonstra no DBeaver, e tudo o que é feito nele pode ser feito no DataGrip.
- [ ] **ERD Concepts**, para criar diagramas. O professor informa o link na aula.
- [ ] **Navegador atualizado** (Chrome ou Edge).
- [ ] **Conta Google** com acesso à turma no Google Classroom.
- [ ] **Git**, instalado e configurado com o seu nome e e-mail (`git config --global user.name` e `user.email`).
  Site oficial: https://git-scm.com/downloads
- [ ] **GitKraken Desktop**, para enviar o projeto ao GitHub sem usar comandos. É gratuito para repositórios públicos, e os
  repositórios dos grupos serão públicos. Site oficial: https://www.gitkraken.com/download
  Na primeira abertura, entre com a sua conta do GitHub.
- [ ] **Conta no GitHub** (https://github.com). O grupo vai criar um repositório e enviar o projeto de cada prova para lá.

## Teste rápido

1. Abra o seu cliente (DBeaver ou DataGrip) e conecte ao PostgreSQL em `localhost:5432`.
2. Crie um banco chamado `teste`.
3. Abra o terminal e rode `psql --version`.
4. Abra o ERD Concepts e crie um diagrama com uma tabela.
5. Abra o Google Classroom da turma.
6. Abra o GitKraken e entre com a sua conta do GitHub.

Se algum passo falhar, avise o professor durante a aula.

## Para mais tarde (aula 22)

Você vai precisar de **Python 3.12 ou superior**, **uv** e **VS Code**.
