BEGIN;

CREATE TABLE sources (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE managers (
    manager_id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE statuses (
    code TEXT PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    position SMALLINT NOT NULL CHECK (position >= 1),
    is_terminal BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE leads (
    lead_id BIGSERIAL PRIMARY KEY,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    source_code TEXT NOT NULL
        REFERENCES sources(code),

    current_stage TEXT NOT NULL
        REFERENCES statuses(code),

    owner_id BIGINT
        REFERENCES managers(manager_id)
);

CREATE TABLE lead_stages (
    stage_id BIGSERIAL PRIMARY KEY,

    lead_id BIGINT NOT NULL
        REFERENCES leads(lead_id)
        ON DELETE CASCADE,

    stage TEXT NOT NULL
        REFERENCES statuses(code),

    entered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    left_at TIMESTAMPTZ,

    changed_by TEXT,

    reason TEXT,

    CHECK (
        left_at IS NULL
        OR left_at >= entered_at
    )
);

CREATE TABLE import_log (
    import_id BIGSERIAL PRIMARY KEY,

    import_key TEXT NOT NULL UNIQUE,

    filename TEXT NOT NULL,

    imported_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    accepted_count INTEGER NOT NULL DEFAULT 0
        CHECK (accepted_count >= 0),

    rejected_count INTEGER NOT NULL DEFAULT 0
        CHECK (rejected_count >= 0)
);

INSERT INTO statuses (
    code,
    name,
    position,
    is_terminal
)
VALUES
    ('new',       'Новый',       1, FALSE),
    ('qualified', 'Квалифицирован', 2, FALSE),
    ('proposal',  'Предложение', 3, FALSE),
    ('won',       'Успешно',     4, TRUE),
    ('lost',      'Потерян',     4, TRUE);


CREATE INDEX idx_leads_source
    ON leads(source_code);

CREATE INDEX idx_leads_stage
    ON leads(current_stage);

CREATE INDEX idx_leads_owner
    ON leads(owner_id);

CREATE INDEX idx_lead_stages_lead
    ON lead_stages(lead_id);


COMMIT;
