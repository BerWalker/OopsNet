CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    image_url TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS reviews (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (name, description, price, image_url) VALUES
('XDR Core Shield', 'Next-generation Extended Detection and Response (XDR) platform. Unified visibility across endpoints, networks, and cloud workloads.', 299.99, 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?q=80&w=800'),
('Pentest Suite Pro', 'Automated security assessment tool with advanced vulnerability scanning and exploitation simulation capabilities.', 149.50, 'https://images.unsplash.com/photo-1614064641938-3bbee52942c7?q=80&w=800'),
('Zero-Trust Gateway', 'Secure access service edge (SASE) solution implementing strictly enforced zero-trust principles for remote workforces.', 199.00, 'https://images.unsplash.com/photo-1563986768609-322da13575f3?q=80&w=800'),
('Encrypted Mesh Node', 'Hardened hardware security module providing end-to-end encrypted communication for critical infrastructure.', 595.00, 'https://images.unsplash.com/photo-1518770660439-4636190af475?q=80&w=800'),
('SIEM Analytics Engine', 'Real-time threat intelligence and log analysis platform with machine learning-driven anomaly detection.', 350.00, 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?q=80&w=800'),
('Quantum Key Vault', 'Ultra-secure digital asset storage using post-quantum cryptographic algorithms and biometrically enforced access.', 899.00, 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?q=80&w=800');
