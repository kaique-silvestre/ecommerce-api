// ===== CONFIGURAÇÕES GLOBAIS =====
const API_URL = 'http://localhost:5093/ECommerceApi';

// ===== SISTEMA DE TEMA (DARK/LIGHT MODE) =====
const ThemeManager = {
    init() {
        const savedTheme = localStorage.getItem('theme') || 'light';
        this.setTheme(savedTheme);
        
        // Listeners for toggle buttons
        document.addEventListener('DOMContentLoaded', () => {
            const toggleBtns = document.querySelectorAll('.theme-toggle');
            toggleBtns.forEach(btn => {
                btn.addEventListener('click', () => this.toggleTheme());
            });
            this.updateIcons();
        });
    },

    toggleTheme() {
        const currentTheme = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        this.setTheme(currentTheme);
    },

    setTheme(theme) {
        document.documentElement.setAttribute('data-theme', theme);
        localStorage.setItem('theme', theme);
        this.updateIcons();
    },

    updateIcons() {
        const isDark = document.documentElement.getAttribute('data-theme') === 'dark';
        const icons = document.querySelectorAll('.theme-toggle i');
        icons.forEach(icon => {
            if (isDark) {
                icon.className = 'fas fa-sun'; // Show sun in dark mode
            } else {
                icon.className = 'fas fa-moon'; // Show moon in light mode
            }
        });
    }
};

// Start theme manager securely early
ThemeManager.init();

// ===== SISTEMA DE NOTIFICAÇÕES (TOAST) =====
const Toast = {
    show(message, type = 'success') { // type: 'success', 'error', 'info'
        let container = document.getElementById('toast-container');
        if (!container) {
            container = document.createElement('div');
            container.id = 'toast-container';
            container.className = 'toast-container';
            document.body.appendChild(container);
        }

        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        
        const iconClasses = {
            success: 'fa-check-circle',
            error: 'fa-exclamation-circle',
            info: 'fa-info-circle'
        };
        
        const iconColor = type === 'success' ? 'var(--success-500)' : 
                          type === 'error' ? 'var(--error-500)' : 'var(--primary-500)';

        toast.innerHTML = `
            <i class="fas ${iconClasses[type]}" style="color: ${iconColor}; font-size: 1.5rem;"></i>
            <div style="font-weight: 500;">${message}</div>
        `;

        container.appendChild(toast);

        // Remove após 3 segundos
        setTimeout(() => {
            toast.classList.add('hide');
            setTimeout(() => toast.remove(), 400); // Aguarda animação
        }, 3000);
    }
};

// ===== COMUNICAÇÃO COM A API (SERVICES) =====
const ProductService = {
    async getAll() {
        try {
            const response = await fetch(API_URL);
            if (!response.ok) throw new Error('Falha ao buscar produtos');
            return await response.json();
        } catch (error) {
            console.error('API Error (GET):', error);
            Toast.show('Não foi possível conectar ao servidor.', 'error');
            return [];
        }
    },

    async getById(id) {
        try {
            const response = await fetch(`${API_URL}/${id}`);
            if (!response.ok) throw new Error('Produto não encontrado');
            return await response.json();
        } catch (error) {
            console.error('API Error (GET ID):', error);
            return null;
        }
    },

    async create(product) {
        try {
            const response = await fetch(API_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(product)
            });
            if (!response.ok) throw new Error('Falha ao criar produto');
            return await response.json();
        } catch (error) {
            console.error('API Error (POST):', error);
            throw error;
        }
    }
    
    // (Futuro) Implementar update e delete quando backend estiver pronto.
};

// Formatação utilitária Global
const FormatUtils = {
    currency(value) {
        return new Intl.NumberFormat('pt-BR', {
            style: 'currency',
            currency: 'BRL'
        }).format(value);
    }
};
