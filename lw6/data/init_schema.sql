CREATE TABLE tree_of_life.tree_of_life_node
(
    id         INT          NOT NULL,
    name       VARCHAR(200) NOT NULL,
    extinct    BOOLEAN      NOT NULL,
    confidence INT          NOT NULL,
    PRIMARY KEY (id)
);

-- Хранит структуру дерева в виде Closure Table
CREATE TABLE tree_of_life.tree_of_life_closure_table
(
    node_id     INT NOT NULL,
    ancestor_id INT NOT NULL,
    distance    INT NOT NULL,
    is_root     BOOL NOT NULL,
    PRIMARY KEY (node_id, ancestor_id),
    INDEX parent_id_distance_idx (ancestor_id, distance),
    CONSTRAINT tol_closure_table_node_id
        FOREIGN KEY (node_id) REFERENCES tree_of_life_node (id) ON DELETE CASCADE,
    CONSTRAINT tol_closure_table_parent_id
        FOREIGN KEY (ancestor_id) REFERENCES tree_of_life_node (id) ON DELETE CASCADE
);
