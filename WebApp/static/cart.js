// Cart logic using LocalStorage
class Cart {
    constructor() {
        this.items = JSON.parse(localStorage.getItem('cyber_cart')) || [];
        this.updateCartCount();
    }

    addItem(product) {
        const existingItem = this.items.find(item => item.id === product.id);
        if (existingItem) {
            existingItem.quantity += 1;
        } else {
            this.items.push({ ...product, quantity: 1 });
        }
        this.save();
        this.updateCartCount();
        this.showNotification(`${product.name} added to cart`);
    }

    removeItem(productId) {
        this.items = this.items.filter(item => item.id !== productId);
        this.save();
        this.updateCartCount();
        this.renderCartPage(); // If on cart page
    }

    updateQuantity(productId, delta) {
        const item = this.items.find(item => item.id === productId);
        if (item) {
            item.quantity += delta;
            if (item.quantity <= 0) {
                this.removeItem(productId);
            } else {
                this.save();
                this.updateCartCount();
                this.renderCartPage();
            }
        }
    }

    save() {
        localStorage.setItem('cyber_cart', JSON.stringify(this.items));
    }

    getTotal() {
        return this.items.reduce((sum, item) => sum + (item.price * item.quantity), 0);
    }

    updateCartCount() {
        const count = this.items.reduce((sum, item) => sum + item.quantity, 0);
        const countEl = document.getElementById('cart-count');
        if (countEl) {
            countEl.textContent = count;
        }
    }

    showNotification(message) {
        const toast = document.createElement('div');
        toast.style.position = 'fixed';
        toast.style.bottom = '20px';
        toast.style.right = '20px';
        toast.style.background = 'var(--accent-color)';
        toast.style.color = 'white';
        toast.style.padding = '1rem 2rem';
        toast.style.borderRadius = '4px';
        toast.style.zIndex = '2000';
        toast.style.fontFamily = 'var(--font-mono)';
        toast.textContent = message;
        document.body.appendChild(toast);
        setTimeout(() => toast.remove(), 3000);
    }

    renderCartPage() {
        const cartContainer = document.getElementById('cart-items-container');
        if (!cartContainer) return;

        if (this.items.length === 0) {
            cartContainer.innerHTML = `
                <div style="text-align:center; padding: 6rem 0;">
                    <p style="font-size: 1.2rem; color: #666; margin-bottom: 2rem;">YOUR_CART_IS_EMPTY</p>
                    <a href="/products" class="btn btn-outline" style="padding: 1rem 3rem;">&larr; BACK_TO_SOLUTIONS</a>
                </div>
            `;
            document.getElementById('cart-summary').style.display = 'none';
            return;
        }

        let html = '';
        this.items.forEach(item => {
            html += `
                <div class="cart-item">
                    <img src="${item.image_url}" alt="${item.name}">
                    <div>
                        <h3>${item.name}</h3>
                        <p class="price">$${item.price.toFixed(2)}</p>
                    </div>
                    <div style="display:flex; align-items:center; gap: 1rem;">
                        <button class="btn btn-outline" onclick="cart.updateQuantity(${item.id}, -1)">-</button>
                        <span>${item.quantity}</span>
                        <button class="btn btn-outline" onclick="cart.updateQuantity(${item.id}, 1)">+</button>
                    </div>
                    <button class="btn btn-outline" onclick="cart.removeItem(${item.id})">REMOVE</button>
                </div>
            `;
        });
        cartContainer.innerHTML = html;
        document.getElementById('total-amount').textContent = `$${this.getTotal().toFixed(2)}`;
    }
}

const cart = new Cart();

// Reveal animations on scroll
const observerOptions = {
    threshold: 0.1
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('active');
        }
    });
}, observerOptions);

document.addEventListener('DOMContentLoaded', () => {
    document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
    
    // Navbar scroll interaction
    const header = document.querySelector('header');
    const handleScroll = () => {
        if (window.scrollY > 50) {
            header.classList.add('header-visible');
        } else {
            // Only hide on home page at top
            if (window.location.pathname === '/' || window.location.pathname === '/index') {
                header.classList.remove('header-visible');
            } else {
                header.classList.add('header-visible');
            }
        }
    };

    window.addEventListener('scroll', handleScroll);
    handleScroll(); // Initial check

    // If on product page, handle review submission
    const reviewForm = document.getElementById('review-form');
    if (reviewForm) {
        reviewForm.addEventListener('submit', async (e) => {
            e.preventDefault();
            const data = {
                product_id: parseInt(document.getElementById('product_id').value),
                rating: parseInt(document.getElementById('rating').value),
                comment: document.getElementById('comment').value
            };

            const response = await fetch('/api/reviews', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            if (response.ok) {
                location.reload();
            } else {
                alert('Failed to submit review');
            }
        });
    }

    // Checkout button
    const checkoutBtn = document.getElementById('checkout-btn');
    if (checkoutBtn) {
        checkoutBtn.addEventListener('click', () => {
            window.location.href = '/checkout';
        });
    }
});
