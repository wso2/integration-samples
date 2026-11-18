# Contract Review Assistant

## Description

An AI agent that reviews non-disclosure agreements (NDAs) and other vendor agreements against the company's contract playbook. The business pastes an agreement into chat. The agent compares each clause with the playbook's standard position, fallback, and red flags, and checks for protections that the agreement leaves out. It returns the clauses that need attention with a risk level and replacement wording, and recommends whether to approve the agreement or send it to the legal team.

The playbook is a Markdown file that is loaded into a vector knowledge base when the integration starts. Replace it with your own playbook to review agreements against your company's rules.

## Prerequisites

- An OpenAI API key. The agent uses OpenAI `gpt-4.1` for the model and `text-embedding-3-small` to index the playbook.

## Configuration

Provide the configuration through a `Config.toml` file in the project root:

```toml
openAiApiKey = "<OPENAI_API_KEY>"

# Path to the contract playbook. Defaults to the sample NDA playbook in this project.
playbookPath = "contract-playbook.md"
```

## Usage Instructions

1. Run the integration using the **Run** button. The playbook is loaded into the knowledge base, and the chat service starts.
2. Send the sample agreement in `sample-nda.md` to the chat service. This command uses `jq` to put the file in the request:

   ```bash
   curl -X POST http://localhost:9090/contract-review/chat \
     -H "Content-Type: application/json" \
     -d "$(jq -n --rawfile nda sample-nda.md '{sessionId: "review-1", message: ("Please review this NDA:\n\n" + $nda)}')"
   ```

   The sample NDA has several clauses that the playbook does not allow, so the review recommends sending it to legal:

   ```markdown
   ## Findings
   1. **Feedback**
      - Clause: "Any feedback, suggestions, or ideas that the Company provides about Northwind's products become the property of Northwind..."
      - Playbook: "Any clause that assigns or licenses the company's intellectual property, or that gives the other party ownership of feedback, ideas, or work product." (red flag)
      - Risk: HIGH
      - Suggestion: Each party keeps ownership of its own feedback and ideas.
   ...

   ## Missing protections
   - **Exclusions:** The agreement does not exclude information that is public, already known, received from a third party, or independently developed.
   ...

   ## Recommendation
   Send to legal. The NDA has several red flags and is missing required protections.
   ```

3. Ask a follow-up question in the same session, for example:

   ```bash
   curl -X POST http://localhost:9090/contract-review/chat \
     -H "Content-Type: application/json" \
     -d '{"sessionId": "review-1", "message": "Northwind cannot accept New York law. What else can we accept, and what should I reply?"}'
   ```

   The agent answers from the playbook, with the fallback governing laws and a suggested reply.

4. Review an agreement that follows the playbook, for example by changing the sample NDA to match the standard positions. The recommendation is "Approve as is".

## How It Works

- **Agent Chat trigger** (`/contract-review/chat`): passes each message to the agent and returns its answer. The session ID keeps the conversation, so follow-up questions refer to the earlier review.
- **Agent**: uses OpenAI `gpt-4.1`. For each clause of the agreement, it searches the playbook and classifies the clause in a fixed order:
  - a red flag is HIGH risk;
  - the standard position, or better, is not reported;
  - the fallback is MEDIUM risk;
  - anything else is HIGH risk.

  It also checks for the protections that every NDA must give: mutuality, exclusions, and compelled disclosure. It recommends:
  - "Send to legal" if any risk is HIGH or a protection is missing;
  - "Approve with the suggested changes" if any risk is MEDIUM;
  - "Approve as is" otherwise.
- **searchPlaybook tool**: retrieves the playbook sections that match a clause topic from the knowledge base.
- **Knowledge base**: a vector knowledge base with an in-memory vector store and OpenAI embeddings. When the integration starts, `loadPlaybook` loads the playbook file and indexes it. Markdown is split at its headings, so each clause's rules are retrieved together. To keep the playbook between restarts or share it across instances, use a persistent vector store, such as pgvector, Pinecone, or Weaviate.
- **Memory**: short-term memory that keeps up to 100 messages per session. When a session grows longer, older messages are summarized instead of dropped, so long reviews keep their context.
- The sample playbook (`contract-playbook.md`) covers 16 NDA topics, including confidentiality, term, residuals, liability, non-solicitation, governing law, and assignment. It is an example for this sample, not legal advice.
