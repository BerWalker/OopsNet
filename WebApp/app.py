import os
import secrets
import string
from flask import Flask, render_template, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.environ.get('DATABASE_URL')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = os.environ.get('FLASK_SECRET_KEY')

db = SQLAlchemy(app)

class Product(db.Model):
    __tablename__ = 'products'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    description = db.Column(db.Text, nullable=False)
    price = db.Column(db.Numeric(10, 2), nullable=False)
    image_url = db.Column(db.Text, nullable=False)

    def to_dict(self):
        return {
            'id': self.id,
            'name': self.name,
            'description': self.description,
            'price': float(self.price),
            'image_url': self.image_url
        }

class Review(db.Model):
    __tablename__ = 'reviews'
    id = db.Column(db.Integer, primary_key=True)
    product_id = db.Column(db.Integer, db.ForeignKey('products.id'))
    rating = db.Column(db.Integer, nullable=False)
    comment = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            'id': self.id,
            'product_id': self.product_id,
            'rating': self.rating,
            'comment': self.comment,
            'created_at': self.created_at.strftime('%Y-%m-%d %H:%M:%S')
        }

@app.route('/')
def index():
    return render_template('landing.html')

@app.route('/products')
def products():
    products = Product.query.all()
    return render_template('products.html', products=products)

@app.route('/product/<int:product_id>')
def product_detail(product_id):
    product = Product.query.get_or_404(product_id)
    reviews = Review.query.filter_by(product_id=product_id).order_by(Review.created_at.desc()).all()
    return render_template('product.html', product=product, reviews=reviews)

@app.route('/cart')
def cart():
    return render_template('cart.html')

@app.route('/checkout')
def checkout_page():
    return render_template('checkout.html')

@app.route('/api/reviews', methods=['POST'])
def add_review():
    data = request.json
    if not data or not all(k in data for k in ('product_id', 'rating', 'comment')):
        return jsonify({'error': 'Missing data'}), 400
    
    new_review = Review(
        product_id=data['product_id'],
        rating=max(1, min(5, data['rating'])),
        comment=data['comment'].strip()
    )
    db.session.add(new_review)
    db.session.commit()
    return jsonify(new_review.to_dict()), 201

def luhn_checksum(card_number):
    """Simple Luhn Algorithm to validate credit card numbers."""
    try:
        digits = [int(d) for d in str(card_number).replace(' ', '').replace('-', '')]
        checksum = 0
        reverse_digits = digits[::-1]
        for i, digit in enumerate(reverse_digits):
            if i % 2 == 1:
                doubled = digit * 2
                if doubled > 9:
                    doubled -= 9
                checksum += doubled
            else:
                checksum += digit
        return checksum % 10 == 0
    except ValueError:
        return False

def is_expiry_valid(expiry_str):
    """Checks if MM/YY format is valid and not in the past."""
    from datetime import datetime
    try:
        # MM/YY
        parts = expiry_str.replace(' ', '').split('/')
        if len(parts) != 2:
            return False
        month, year = map(int, parts)
        if not (1 <= month <= 12):
            return False
        
        year += 2000 # Assuming 21st century
        now = datetime.now()
        if year < now.year:
            return False
        if year == now.year and month < now.month:
            return False
        return True
    except (ValueError, IndexError):
        return False

@app.route('/api/checkout', methods=['POST'])
def checkout():
    data = request.json
    card_number = data.get('card_num', '')
    expiry = data.get('expiry', '')
    
    if not card_number or not luhn_checksum(card_number):
        return jsonify({'status': 'error', 'message': 'INVALID_SECURITY_TOKEN // CARD_VALIDATION_FAILED'}), 400

    if not expiry or not is_expiry_valid(expiry):
        return jsonify({'status': 'error', 'message': 'INVALID_PROTOCOL // EXPIRY_DATE_VALIDATION_FAILED'}), 400

    # Simulated checkout with info
    order_id = ''.join(secrets.choice(string.ascii_uppercase + string.digits) for _ in range(8))
    return jsonify({
        'status': 'success', 
        'message': f'Order processed for {data.get("full_name", "Customer")}!',
        'order_id': order_id,
        'user_info': {
            'name': data.get('full_name'),
            'email': data.get('email')
        }
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
