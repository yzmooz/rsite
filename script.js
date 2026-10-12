"use strict";

if (window.lucide) {
    window.lucide.createIcons();
}

document.querySelectorAll("[data-dialog]").forEach((trigger) => {
    trigger.addEventListener("click", () => {
        const dialog = document.getElementById(trigger.dataset.dialog);
        if (!dialog || dialog.open) return;
        dialog.showModal();
        document.body.classList.add("modal-open");
    });
});

document.querySelectorAll("dialog").forEach((dialog) => {
    dialog.querySelector("[data-close]").addEventListener("click", () => dialog.close());
    dialog.addEventListener("keydown", (event) => {
        if (event.key !== "Tab") return;
        const controls = [...dialog.querySelectorAll('button, a[href], input, select, textarea, [tabindex="0"]')];
        const first = controls[0];
        const last = controls[controls.length - 1];
        if (event.shiftKey && document.activeElement === first) {
            event.preventDefault();
            last.focus();
        } else if (!event.shiftKey && document.activeElement === last) {
            event.preventDefault();
            first.focus();
        }
    });
    // A backdrop click targets the dialog too; exclude clicks inside its bounds.
    dialog.addEventListener("click", (event) => {
        const bounds = dialog.getBoundingClientRect();
        if (event.target === dialog && (event.clientX < bounds.left || event.clientX > bounds.right ||
            event.clientY < bounds.top || event.clientY > bounds.bottom)) {
            dialog.close();
        }
    });
    dialog.addEventListener("close", () => {
        document.body.classList.remove("modal-open");
    });
});
