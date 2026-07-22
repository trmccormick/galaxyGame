// Admin Catalog JavaScript
// Handles search debounce, filter changes, and collapsible panels

document.addEventListener('DOMContentLoaded', function() {
  // Search debounce
  const searchInput = document.getElementById('catalog-search');
  if (searchInput) {
    let debounceTimer;
    searchInput.addEventListener('input', function() {
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(function() {
        // Submit form after debounce
        const form = searchInput.closest('.search-form');
        if (form) {
          const query = searchInput.value.trim();
          const url = new URL(form.action, window.location.origin);
          url.searchParams.set('q', query);

          // Preserve other filters
          const categoryFilter = document.getElementById('category-filter');
          if (categoryFilter && categoryFilter.value) {
            url.searchParams.set('category', categoryFilter.value);
          }
          const subcategoryFilter = document.getElementById('subcategory-filter');
          if (subcategoryFilter && subcategoryFilter.value) {
            url.searchParams.set('subcategory', subcategoryFilter.value);
          }

          window.location.href = url.toString();
        }
      }, 300);
    });
  }

  // Filter change handler (for select elements)
  const categoryFilter = document.getElementById('category-filter');
  const subcategoryFilter = document.getElementById('subcategory-filter');

  function applyFilters() {
    const url = new URL(window.location.pathname, window.location.origin);

    if (categoryFilter && categoryFilter.value) {
      url.searchParams.set('category', categoryFilter.value);
    } else {
      url.searchParams.delete('category');
    }

    if (subcategoryFilter && subcategoryFilter.value) {
      url.searchParams.set('subcategory', subcategoryFilter.value);
    } else {
      url.searchParams.delete('subcategory');
    }

    // Preserve search query
    const searchInput = document.getElementById('catalog-search');
    if (searchInput && searchInput.value.trim()) {
      url.searchParams.set('q', searchInput.value.trim());
    }

    window.location.href = url.toString();
  }

  if (categoryFilter) {
    categoryFilter.addEventListener('change', applyFilters);
  }
  if (subcategoryFilter) {
    subcategoryFilter.addEventListener('change', applyFilters);
  }

  // Initialize collapsible panels on the page
  initCollapsiblePanels();
});

// Toggle collapsible panel
function togglePanel(button) {
  const content = button.nextElementSibling;
  const icon = button.querySelector('i');

  if (content.classList.contains('open')) {
    content.classList.remove('open');
    icon.className = 'fas fa-code';
    button.innerHTML = '<i class="fas fa-code"></i> Show JSON Data';
  } else {
    content.classList.add('open');
    icon.className = 'fas fa-code-branch';
    button.innerHTML = '<i class="fas fa-code-branch"></i> Hide JSON Data';
  }
}

// Initialize collapsible panels (for pages loaded via AJAX or initial load)
function initCollapsiblePanels() {
  const toggles = document.querySelectorAll('.panel-toggle');
  toggles.forEach(function(toggle) {
    // Remove existing listeners to prevent duplicates
    const cloned = toggle.cloneNode(true);
    toggle.parentNode.replaceChild(cloned, toggle);

    cloned.addEventListener('click', function() {
      togglePanel(this);
    });
  });
}
