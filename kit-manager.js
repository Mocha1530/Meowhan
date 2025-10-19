// Kit Manager class to handle saving, loading, and managing kits
class KitManager {
    constructor() {
        this.kits = JSON.parse(localStorage.getItem('savedKits') || '{}');
        this.setupEventListeners();
        
        // Add event listener to update commands when kit name changes
        const kitNameInput = document.getElementById('kit-name');
        kitNameInput.addEventListener('input', () => {
            setTimeout(() => {
                commandsOutput.value = generateCommands();
            }, 0);
        });

        // Add event listener to update commands when kit items change
        document.querySelectorAll('.slot').forEach(slot => {
            slot.addEventListener('change', () => {
                setTimeout(() => {
                    output.value = generateCommands();
                }, 0);
            });
        });
    }

    setupEventListeners() {
        document.getElementById('save-kit').addEventListener('click', () => this.saveCurrentKit());
        document.getElementById('load-kit').addEventListener('click', () => this.showLoadDialog());
        document.getElementById('manage-kits').addEventListener('click', () => this.showManageDialog());
        document.getElementById('import-Kit').addEventListener('click', () => this.showImportDialog());
    }

    saveCurrentKit() {
        const kitName = document.getElementById('kit-name').value.trim();
        if (!kitName) {
            Toast.error('Please enter a kit name');
            return;
        }

        const kitData = this.getCurrentKitData();
        this.kits[kitName] = kitData;
        this.saveKitsToStorage();
        Toast.success(`Kit "${kitName}" saved successfully!`);
    }

    getCurrentKitData() {
        const kitData = {
            name: document.getElementById('kit-name').value.trim(),
            items: []
        };

        document.querySelectorAll('.slot').forEach(slot => {
            const itemId = slot.dataset.itemId;
            if (itemId) {
                const qtyInput = slot.querySelector('.qty-input');
                const quantity = qtyInput ? parseInt(qtyInput.value) : 1;
                const slotType = slot.dataset.slotType;
                const slotIndex = parseInt(slot.dataset.slotIndex);

                kitData.items.push({
                    itemId,
                    quantity,
                    slotType,
                    slotIndex
                });
            }
        });

        return kitData;
    }

    function buildImageUrl(imagePath) {
        if (!imagePath) return "https://kb.veretech.systems/images/placeholder.png";
        
        let cleanPath = imagePath.replace(/^\.\//, '');
        
        return `https://kb.veretech.systems/${cleanPath}.png`;
    }

    loadKit(kitName) {
        const kitData = this.kits[kitName];
        if (!kitData) {
            Toast.error('Kit not found');
            return;
        }

        // Clear current kit
        document.getElementById('clear-all').click();

        // Set kit name and make it editable
        const kitNameInput = document.getElementById('kit-name');
        kitNameInput.value = kitName;
        kitNameInput.disabled = false;
        kitNameInput.readOnly = false;

        // Load items
        kitData.items.forEach(item => {
            const slot = document.querySelector(`.slot[data-slot-type="${item.slotType}"][data-slot-index="${item.slotIndex}"]`);
            if (slot) {
                // Set the item data on the slot
                slot.dataset.itemId = item.itemId;
                slot.dataset.itemName = this.getItemName(item.itemId);

                // Create the slot item container
                const slotItem = document.createElement('div');
                slotItem.className = 'slot-item';
                slotItem.draggable = true;

                // Create and add the item image
                const slotImg = document.createElement('img');
                slotImg.classList.add('slotted-item');
                slotImg.alt = this.getItemName(item.itemId);
                slotImg.src = buildImageUrl(this.findItemImagePath(data.id));
                slotImg.onerror = () => {
                    slotImg.src = "https://kb.veretech.systems/images/placeholder.png";
                };
                slotItem.appendChild(slotImg);

                // Create and add the quantity input
                const qtyInput = document.createElement('input');
                qtyInput.type = 'number';
                qtyInput.classList.add('qty-input');
                qtyInput.value = item.quantity;
                qtyInput.min = 1;
                qtyInput.addEventListener('click', (e) => {
                    e.stopPropagation();
                });
                if (slot.dataset.slotType === 'wear') {
                    qtyInput.disabled = true;
                } else {
                    qtyInput.addEventListener('change', () => {
                        output.value = generateCommands();
                    });
                }
                slotItem.appendChild(qtyInput);

                // Add dragstart event to the slot item
                slotItem.addEventListener('dragstart', (ev) => {
                    ev.dataTransfer.setData('text/plain', JSON.stringify({
                        itemId: slot.dataset.itemId,
                        itemName: slot.dataset.itemName,
                        slotType: slot.dataset.slotType,
                        slotIndex: slot.dataset.slotIndex
                    }));
                });

                // Add remove button
                const removeBtn = document.createElement('button');
                removeBtn.classList.add('remove-item');
                removeBtn.textContent = 'x';
                removeBtn.addEventListener('click', (e) => {
                    e.stopPropagation();
                    slot.innerHTML = '';
                    delete slot.dataset.itemId;
                    delete slot.dataset.itemName;
                    updateWearLockStatus();
                    output.value = generateCommands();
                });

                // Add the slot item to the slot
                slot.appendChild(slotItem);
                slot.appendChild(removeBtn);
            }
        });

        // Add drag and drop event listeners to all slots after loading items
        document.querySelectorAll('.slot').forEach(slot => {
            slot.addEventListener('dragover', (e) => {
                e.preventDefault();
            });

            slot.addEventListener('drop', (e) => {
                e.preventDefault();
                const data = JSON.parse(e.dataTransfer.getData('text/plain'));
                if (data.slotType === slot.dataset.slotType) {
                    // Clear the target slot first
                    slot.innerHTML = '';
                    delete slot.dataset.itemId;
                    delete slot.dataset.itemName;
                    
                    // Create new slot item
                    const newSlotItem = document.createElement('div');
                    newSlotItem.className = 'slot-item';
                    newSlotItem.draggable = true;

                    // Add item image
                    const newSlotImg = document.createElement('img');
                    newSlotImg.classList.add('slotted-item');
                    newSlotImg.alt = data.itemName;
                    slotImg.src = buildImageUrl(this.findItemImagePath(data.id));
                    slotImg.onerror = () => {
                        slotImg.src = "https://kb.veretech.systems/images/placeholder.png";
                    };
                    newSlotItem.appendChild(newSlotImg);

                    // Add quantity input
                    const newQtyInput = document.createElement('input');
                    newQtyInput.type = 'number';
                    newQtyInput.classList.add('qty-input');
                    newQtyInput.value = 1;
                    newQtyInput.min = 1;
                    newQtyInput.addEventListener('click', (e) => {
                        e.stopPropagation();
                    });
                    if (slot.dataset.slotType === 'wear') {
                        newQtyInput.disabled = true;
                    } else {
                        newQtyInput.addEventListener('change', () => {
                            output.value = generateCommands();
                        });
                    }
                    newSlotItem.appendChild(newQtyInput);

                    // Add dragstart event
                    newSlotItem.addEventListener('dragstart', (ev) => {
                        ev.dataTransfer.setData('text/plain', JSON.stringify({
                            itemId: data.itemId,
                            itemName: data.itemName,
                            slotType: slot.dataset.slotType,
                            slotIndex: slot.dataset.slotIndex
                        }));
                    });

                    // Add remove button
                    const newRemoveBtn = document.createElement('button');
                    newRemoveBtn.classList.add('remove-item');
                    newRemoveBtn.textContent = 'x';
                    newRemoveBtn.addEventListener('click', (e) => {
                        e.stopPropagation();
                        slot.innerHTML = '';
                        delete slot.dataset.itemId;
                        delete slot.dataset.itemName;
                        updateWearLockStatus();
                        output.value = generateCommands();
                    });

                    // Update slot data
                    slot.dataset.itemId = data.itemId;
                    slot.dataset.itemName = data.itemName;

                    // Add elements to slot
                    slot.appendChild(newSlotItem);
                    slot.appendChild(newRemoveBtn);

                    // Update commands
                    output.value = generateCommands();
                }
            });
        });

        // Add drag and drop event listener to the document body to handle dragging items out of the slots
        document.body.addEventListener('dragover', (e) => {
            e.preventDefault();
        });

        document.body.addEventListener('drop', (e) => {
            e.preventDefault();
            const data = JSON.parse(e.dataTransfer.getData('text/plain'));
            const slot = document.querySelector(`.slot[data-slot-type="${data.slotType}"][data-slot-index="${data.slotIndex}"]`);
            if (slot) {
                slot.innerHTML = '';
                delete slot.dataset.itemId;
                delete slot.dataset.itemName;
                updateWearLockStatus();
                output.value = generateCommands();
            }
        });

        // Update commands after all items are loaded and event listeners are set up
        setTimeout(() => {
            output.value = generateCommands();
        }, 0);
    }

    getItemName(itemId) {
        if (!window.items) return '';
        for (const categoryName of Object.keys(window.items)) {
            const category = window.items[categoryName];
            if (category) {
                // Handle nested structure where categories contain subcategories
                if (Array.isArray(category)) {
                    const item = category.find(i => i.id.toLowerCase() === itemId.toLowerCase());
                    if (item) return item.name;
                } else {
                    // Handle subcategories
                    for (const subcat in category) {
                        if (Array.isArray(category[subcat])) {
                            const item = category[subcat].find(i => i.id.toLowerCase() === itemId.toLowerCase());
                            if (item) return item.name;
                        }
                    }
                }
            }
        }
        return '';
    }

    findItemImagePath(itemId) {
        if (!window.items) return null;
        for (let cat of Object.keys(window.items)) {
            if (window.items[cat]) {
                // Handle nested structure where categories contain subcategories
                if (Array.isArray(window.items[cat])) {
                    const found = window.items[cat].find(i => i.id.toLowerCase() === itemId.toLowerCase());
                    if (found) return found.image;
                } else {
                    // Handle subcategories
                    for (const subcat in window.items[cat]) {
                        if (Array.isArray(window.items[cat][subcat])) {
                            const found = window.items[cat][subcat].find(i => i.id.toLowerCase() === itemId.toLowerCase());
                            if (found) return found.image;
                        }
                    }
                }
            }
        }
        return null;
    }

    showLoadDialog() {
        // Check if there are any kits to load
        if (Object.keys(this.kits).length === 0) {
            Toast.info('No saved kits found');
            return;
        }

        const dialog = document.createElement('div');
        dialog.className = 'kit-dialog';
        dialog.innerHTML = `
            <h3>Load Kit</h3>
            <select id="kitSelect">
                ${Object.keys(this.kits).map(name => `<option value="${name}">${name}</option>`).join('')}
            </select>
            <div class="button-row">
                <button id="loadSelectedKit">Load</button>
                <button id="cancelLoad">Cancel</button>
            </div>
        `;

        // Create and add overlay
        const overlay = document.createElement('div');
        overlay.className = 'dialog-overlay';
        document.body.appendChild(overlay);
        document.body.appendChild(dialog);
        
        // Trigger animation
        requestAnimationFrame(() => {
            overlay.classList.add('show');
            dialog.classList.add('show');
        });
        
        // Function to close dialog with animation
        const closeDialog = (callback) => {
            overlay.classList.add('hide');
            dialog.classList.add('hide');
            
            setTimeout(() => {
                dialog.remove();
                overlay.remove();
                if (callback) callback();
            }, 300); // Match the CSS transition duration
        };

        // Handle load button click
        document.getElementById('loadSelectedKit').addEventListener('click', () => {
            const selectedKit = document.getElementById('kitSelect').value;
            closeDialog(() => {
                // Then load the kit
                this.loadKit(selectedKit);
                // Update commands immediately after loading
                output.value = generateCommands();
                Toast.success(`Kit "${selectedKit}" loaded successfully`);
            });
        });

        // Handle cancel button click
        document.getElementById('cancelLoad').addEventListener('click', () => {
            closeDialog();
        });

        // Handle overlay click to close
        overlay.addEventListener('click', () => {
            closeDialog();
        });
    }

    showManageDialog() {
        // Check if there are any kits to manage
        if (Object.keys(this.kits).length === 0) {
            Toast.info('No saved kits found');
            return;
        }

        const dialog = document.createElement('div');
        dialog.className = 'kit-dialog';
        dialog.innerHTML = `
            <h3>Manage Kits</h3>
            <div class="kit-list">
                ${Object.entries(this.kits).map(([name, kit]) => `
                    <div class="kit-item">
                        <span>${name}</span>
                        <div class="kit-actions">
                            <button class="delete-kit" data-kit="${name}">Delete</button>
                        </div>
                    </div>
                `).join('')}
            </div>
            <div class="button-row">
                <button id="closeManage">Close</button>
            </div>
            <div id="deleteConfirmArea" style="margin-top: 15px; display: none;">
                <div style="background: rgba(255, 0, 0, 0.1); border: 1px solid red; padding: 10px; border-radius: 4px;">
                    <p style="margin: 0 0 10px 0;">Are you sure you want to delete kit "<span id="kitToDeleteName"></span>"?</p>
                    <div style="display: flex; gap: 10px;">
                        <button id="confirmDelete" style="background: #F44336; flex: 1;">Yes, Delete</button>
                        <button id="cancelDelete" style="background: #333; flex: 1;">Cancel</button>
                    </div>
                </div>
            </div>
        `;

        // Create and add overlay
        const overlay = document.createElement('div');
        overlay.className = 'dialog-overlay';
        document.body.appendChild(overlay);
        document.body.appendChild(dialog);
        
        // Trigger animation
        requestAnimationFrame(() => {
            overlay.classList.add('show');
            dialog.classList.add('show');
        });
        
        // Function to close dialog with animation
        const closeDialog = (callback) => {
            overlay.classList.add('hide');
            dialog.classList.add('hide');
            
            setTimeout(() => {
                dialog.remove();
                overlay.remove();
                if (callback) callback();
            }, 300); // Match the CSS transition duration
        };

        let kitToDelete = null;
        const confirmArea = document.getElementById('deleteConfirmArea');
        const kitNameSpan = document.getElementById('kitToDeleteName');

        dialog.querySelectorAll('.delete-kit').forEach(button => {
            button.addEventListener('click', (e) => {
                const kitName = e.target.dataset.kit;
                kitToDelete = kitName;
                kitNameSpan.textContent = kitName;
                confirmArea.style.display = 'block';
                
                // Scroll to confirmation area on mobile
                if (/Mobi|Android/i.test(navigator.userAgent)) {
                    setTimeout(() => {
                        confirmArea.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                    }, 100);
                }
            });
        });
        
        // Set up confirmation buttons
        document.getElementById('confirmDelete').addEventListener('click', () => {
            if (kitToDelete) {
                delete this.kits[kitToDelete];
                this.saveKitsToStorage();
                
                // Check if no more kits left
                if (Object.keys(this.kits).length === 0) {
                    closeDialog(() => {
                        Toast.success(`Kit "${kitToDelete}" deleted`);
                        Toast.info('No more kits to manage');
                    });
                    return;
                }
                
                // Find all kit items with matching name
                const kitItems = Array.from(dialog.querySelectorAll('.kit-item')).filter(item => {
                    const span = item.querySelector('span');
                    return span && span.textContent === kitToDelete;
                });
                
                // Remove kit items if found
                if (kitItems.length > 0) {
                    kitItems.forEach(item => item.remove());
                } else {
                    // If kit items not found, redraw the whole list
                    const kitList = dialog.querySelector('.kit-list');
                    kitList.innerHTML = Object.entries(this.kits).map(([name, kit]) => `
                        <div class="kit-item">
                            <span>${name}</span>
                            <div class="kit-actions">
                                <button class="delete-kit" data-kit="${name}">Delete</button>
                            </div>
                        </div>
                    `).join('');
                    
                    // Re-attach event listeners
                    dialog.querySelectorAll('.delete-kit').forEach(button => {
                        button.addEventListener('click', (e) => {
                            const kitName = e.target.dataset.kit;
                            kitToDelete = kitName;
                            kitNameSpan.textContent = kitName;
                            confirmArea.style.display = 'block';
                            
                            // Scroll to confirmation area on mobile
                            if (/Mobi|Android/i.test(navigator.userAgent)) {
                                setTimeout(() => {
                                    confirmArea.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                                }, 100);
                            }
                        });
                    });
                }
                
                Toast.success(`Kit "${kitToDelete}" deleted`);
                confirmArea.style.display = 'none';
                kitToDelete = null;
            }
        });
        
        document.getElementById('cancelDelete').addEventListener('click', () => {
            confirmArea.style.display = 'none';
            kitToDelete = null;
        });

        // Handle close button click
        document.getElementById('closeManage').addEventListener('click', () => {
            closeDialog();
        });

        // Handle overlay click to close
        overlay.addEventListener('click', () => {
            closeDialog();
        });
    }

    showImportDialog() {
        const dialog = document.createElement('div');
        dialog.className = 'kit-dialog';
        
        // Detect if we're on mobile
        const isMobile = /Mobi|Android/i.test(navigator.userAgent);
        
        // Create a more mobile-friendly dialog
        dialog.innerHTML = `
            <h3>Import Kit</h3>
            <div class="import-instructions">
                <p>Paste kit commands or a kit code to import:</p>
            </div>
            <textarea id="importText" placeholder="Paste kit commands here..." style="width: 100%; height: 150px; margin: 10px 0; color: white; background-color: #111; border: 1px solid #0ff; border-radius: 4px; padding: 10px; box-sizing: border-box; max-width: 100%;"></textarea>
            <div class="button-row">
                <button id="importKitData">Import</button>
                <button id="cancelImport">Cancel</button>
            </div>
            <div class="mobile-paste-help" style="margin-top: 10px; font-size: 0.8rem; color: #aaa;">
                <p>On mobile: Press and hold inside the text area to paste from clipboard.</p>
            </div>
        `;

        const overlay = document.createElement('div');
        overlay.className = 'dialog-overlay';
        document.body.appendChild(overlay);
        document.body.appendChild(dialog);
        
        // Mobile-specific adjustments
        if (isMobile) {
            dialog.style.maxWidth = '90%';
            dialog.style.width = '320px';
            dialog.style.boxSizing = 'border-box';
            dialog.style.display = 'flex';
            dialog.style.flexDirection = 'column';
        }
        
        // Trigger animation
        requestAnimationFrame(() => {
            overlay.classList.add('show');
            dialog.classList.add('show');
            
            // Additional fix for mobile rendering
            if (isMobile) {
                const importText = document.getElementById('importText');
                if (importText) {
                    importText.style.width = '100%';
                    importText.style.maxWidth = '100%';
                    importText.style.boxSizing = 'border-box';
                    importText.style.border = '2px solid #f0f';
                    importText.style.color = 'white';
                    importText.style.backgroundColor = '#111';
                }
            }
        });

        const importTextArea = document.getElementById('importText');
        
        // Add extra focus on mobile to help with paste operations
        if (isMobile) {
            importTextArea.addEventListener('focus', () => {
                importTextArea.style.backgroundColor = '#222';
                importTextArea.style.border = '2px solid var(--accent-neon-alt)';
                importTextArea.style.color = 'white';
            });
            
            importTextArea.addEventListener('blur', () => {
                importTextArea.style.backgroundColor = '#111';
                importTextArea.style.border = '2px solid var(--accent-neon-alt)';
                importTextArea.style.color = 'white'; // Ensure text stays white
            });
            
            // Focus the textarea to make it easier for mobile users
            setTimeout(() => importTextArea.focus(), 300);
        }

        // Function to close dialog with animation
        const closeDialog = (callback) => {
            overlay.classList.add('hide');
            dialog.classList.add('hide');
            
            setTimeout(() => {
                dialog.remove();
                overlay.remove();
                if (callback) callback();
            }, 300); // Match the CSS transition duration
        };

        document.getElementById('importKitData').addEventListener('click', () => {
            const importText = document.getElementById('importText').value.trim();
            
            if (!importText) {
                Toast.error('Please paste kit data to import');
                return;
            }
            
            // Check if it's a base64 encoded string and try to decode it
            let textToProcess = importText;
            try {
                // Test if it's a valid base64 string with a simple regex check
                if (/^[A-Za-z0-9+/=]+$/.test(importText)) {
                    const decoded = atob(importText);
                    if (decoded && (decoded.includes('kit add') || decoded.includes('Kit Name:'))) {
                        textToProcess = decoded;
                        Toast.info('Detected and decoded base64 kit data');
                    }
                }
            } catch (e) {
                // If decoding fails, use the original text
                console.error('Failed to decode base64:', e);
            }
            
            // Close the dialog first before parsing
            closeDialog(() => {
                // Then parse and import the kit
                const result = this.parseAndImportKit(textToProcess);
                
                if (result) {
                    Toast.success('Kit imported successfully!');
                }
            });
        });

        document.getElementById('cancelImport').addEventListener('click', () => closeDialog());
        overlay.addEventListener('click', () => closeDialog());
    }

    parseAndImportKit(importText) {
        // Clear current kit first
        document.getElementById('clear-all').click();

        // Handle the case where the text contains \n as literal characters
        const processedText = importText.replace(/\\n/g, '\n');
        const lines = processedText.split('\n');
        let kitName = '';
        let items = [];

        for (let i = 0; i < lines.length; i++) {
            const trimmedLine = lines[i].trim();
            if (!trimmedLine) continue;

            // Skip the [KITMANAGER] header line
            if (trimmedLine.startsWith('[KITMANAGER]')) continue;

            // First line might be the kit name
            if (i === 0 || (i === 1 && lines[0].startsWith('[KITMANAGER]'))) {
                const kitNameMatch = trimmedLine.match(/Kit Name: \[([^\]]+)\]/i);
                if (kitNameMatch) {
                    kitName = kitNameMatch[1];
                    continue;
                }
            }

            // Try to match the first format: kit add kitname itemid qty 1 container
            const format1Match = trimmedLine.match(/kit add "?([^"]+)"? "?([^"]+)"? (\d+) 1 "?(main|wear|belt)"?/i);
            if (format1Match) {
                const [, name, itemId, qty, container] = format1Match;
                if (!kitName) kitName = name;
                items.push({ itemId, qty: parseInt(qty), container: container.toLowerCase() });
                continue;
            }

            // Try to match the second format: Kit Name: [name] ID: [id] Shortname: [shortname] Amount: [amount] Condition: [condition] Container: [container]
            const format2Match = trimmedLine.match(/Kit Name: \[([^\]]+)\] ID: \[([^\]]+)\] Shortname: ([^\s]+) Amount: \[(\d+)\] Condition: \[[^\]]+\] Container: \[([^\]]+)\]/i);
            if (format2Match) {
                const [, name, itemId, , qty, container] = format2Match;
                if (!kitName) kitName = name;
                items.push({ itemId, qty: parseInt(qty), container: container.toLowerCase() });
                continue;
            }

            // Try to match the third format: ID: [number] Shortname: [shortname] Amount: [amount] Condition: [condition] Container: [container]
            const format3Match = trimmedLine.match(/ID: \[([^\]]+)\] Shortname: ([^\s]+) Amount: \[(\d+)\] Condition: \[[^\]]+\] Container: \[([^\]]+)\]/i);
            if (format3Match) {
                const [, , shortname, qty, container] = format3Match;
                items.push({ itemId: shortname, qty: parseInt(qty), container: container.toLowerCase() });
            }
        }

        if (items.length === 0) {
            Toast.error('No valid kit data found in the import text');
            return false;
        }

        // If no kit name was found in the import, use a default name
        if (!kitName) {
            kitName = "Imported Kit";
        }

        // Set the kit name
        const kitNameInput = document.getElementById('kit-name');
        kitNameInput.value = kitName;

        // Place items in their respective slots
        let placedItems = 0;
        
        // Check if we're on mobile
        const isMobile = /Mobi|Android/i.test(navigator.userAgent);
        
        items.forEach(item => {
            let slotType = 'inventory'; // Default to inventory
            if (item.container.toLowerCase() === 'wear') slotType = 'wear';
            else if (item.container.toLowerCase() === 'belt') slotType = 'hotbar';

            const slots = document.querySelectorAll(`.slot[data-slot-type="${slotType}"]`);
            
            // Find an existing slot item with this ID first
            let foundExistingItem = false;
            for (const slot of slots) {
                if (slot.dataset.itemId && slot.dataset.itemId.toLowerCase() === item.itemId.toLowerCase()) {
                    // Update quantity if possible
                    const qtyInput = slot.querySelector('.qty-input');
                    if (qtyInput && slotType !== 'wear') {
                        qtyInput.value = parseInt(qtyInput.value) + item.qty;
                        foundExistingItem = true;
                        placedItems++;
                        break;
                    }
                }
            }
            
            // If not found as existing item, place in a new slot
            if (!foundExistingItem) {
                for (const slot of slots) {
                    if (!slot.dataset.itemId) {
                        // Find the item in our items database
                        let foundItem = null;
                        for (const categoryName of Object.keys(window.items)) {
                            const category = window.items[categoryName];
                            if (category) {
                                // Handle nested structure where categories contain subcategories
                                if (Array.isArray(category)) {
                                    foundItem = category.find(i => i.id.toLowerCase() === item.itemId.toLowerCase());
                                    if (foundItem) break;
                                } else {
                                    // Handle subcategories
                                    for (const subcat in category) {
                                        if (Array.isArray(category[subcat])) {
                                            foundItem = category[subcat].find(i => i.id.toLowerCase() === item.itemId.toLowerCase());
                                            if (foundItem) break;
                                        }
                                    }
                                    if (foundItem) break;
                                }
                            }
                        }
                        if (foundItem) {
                            slot.dataset.itemId = item.itemId;
                            slot.dataset.itemName = foundItem.name;

                            // Create the slot item container with proper mobile styling
                            const slotItem = document.createElement('div');
                            slotItem.className = 'slot-item';
                            slotItem.draggable = true;
                            
                            // Set proper positioning for mobile
                            if (isMobile) {
                                slotItem.style.display = 'flex';
                                slotItem.style.flexDirection = 'column';
                                slotItem.style.justifyContent = 'space-between';
                                slotItem.style.alignItems = 'center';
                                slotItem.style.height = '100%';
                                slotItem.style.width = '100%';
                                slotItem.style.padding = '3px';
                                slotItem.style.boxSizing = 'border-box';
                            }

                            // Add item image
                            const slotImg = document.createElement('img');
                            slotImg.classList.add('slotted-item');
                            slotImg.alt = foundItem.name;
                            
                            // Set better image sizing for mobile
                            if (isMobile) {
                                slotImg.style.maxWidth = '45px';
                                slotImg.style.maxHeight = '45px';
                                slotImg.style.marginBottom = '5px';
                            }
                            
                            slotImg.src = buildImageUrl(this.findItemImagePath(data.id));
                            slotImg.onerror = () => {
                                slotImg.src = "https://kb.veretech.systems/images/placeholder.png";
                            };
                            slotItem.appendChild(slotImg);

                            // Add quantity input with better mobile styling
                            const qtyInput = document.createElement('input');
                            qtyInput.type = 'number';
                            qtyInput.classList.add('qty-input');
                            qtyInput.value = item.qty;
                            qtyInput.min = 1;
                            
                            // Set better input styling for mobile
                            if (isMobile) {
                                qtyInput.style.width = '28px';
                                qtyInput.style.zIndex = '5';
                                qtyInput.style.position = 'relative';
                                qtyInput.style.backgroundColor = '#333';
                                qtyInput.style.border = '1px solid var(--accent-neon)';
                                qtyInput.style.color = 'white';
                                qtyInput.style.textAlign = 'center';
                                qtyInput.style.borderRadius = '3px';
                            }
                            
                            qtyInput.addEventListener('click', (e) => {
                                e.stopPropagation();
                            });
                            if (slotType === 'wear') {
                                qtyInput.disabled = true;
                            } else {
                                qtyInput.addEventListener('change', () => {
                                    output.value = generateCommands();
                                });
                            }
                            slotItem.appendChild(qtyInput);

                            // Add dragstart event
                            slotItem.addEventListener('dragstart', (ev) => {
                                ev.dataTransfer.setData('text/plain', JSON.stringify({
                                    itemId: slot.dataset.itemId,
                                    itemName: slot.dataset.itemName,
                                    slotType: slot.dataset.slotType,
                                    slotIndex: slot.dataset.slotIndex
                                }));
                            });

                            // Add remove button with better mobile positioning
                            const removeBtn = document.createElement('button');
                            removeBtn.classList.add('remove-item');
                            removeBtn.textContent = 'x';
                            
                            // Position the remove button better on mobile
                            if (isMobile) {
                                removeBtn.style.position = 'absolute';
                                removeBtn.style.top = '-5px';
                                removeBtn.style.right = '-5px';
                                removeBtn.style.zIndex = '10';
                                removeBtn.style.width = '20px';
                                removeBtn.style.height = '20px';
                                removeBtn.style.boxShadow = '0 0 3px rgba(0,0,0,0.5)';
                            }
                            
                            removeBtn.addEventListener('click', (e) => {
                                e.stopPropagation();
                                slot.innerHTML = '';
                                delete slot.dataset.itemId;
                                delete slot.dataset.itemName;
                                updateWearLockStatus();
                                output.value = generateCommands();
                            });

                            slot.appendChild(slotItem);
                            slot.appendChild(removeBtn);
                            placedItems++;
                            break;
                        }
                        break;
                    }
                }
            }
        });

        // Show a message if not all items could be placed
        if (placedItems < items.length) {
            Toast.info(`Placed ${placedItems} out of ${items.length} items. Some items may not fit in available slots.`);
        }

        // Update wear lock status
        updateWearLockStatus();

        // Update commands
        output.value = generateCommands();
        
        // Smooth scroll to show the kit content on mobile
        if (isMobile) {
            setTimeout(() => {
                const slotContainer = document.querySelector('.slot-container');
                if (slotContainer) {
                    slotContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            }, 300);
        }
        
        return true;
    }

    saveKitsToStorage() {
        localStorage.setItem('savedKits', JSON.stringify(this.kits));
    }
}

// Initialize kit manager when the page loads
document.addEventListener('DOMContentLoaded', () => {
    window.kitManager = new KitManager();
}); 
