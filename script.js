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
        const controls = [...dialog.querySelectorAll('button, a[href], input, select, textarea, [tabindex="0"]')]
            .filter((control) => !control.disabled && control.getClientRects().length > 0);
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

const galleryTrack = document.getElementById("gallery-track");
const galleryViewer = document.getElementById("gallery-viewer");

if (galleryTrack && galleryViewer) {
    const items = [...galleryTrack.querySelectorAll(".gallery-item")];
    const scrollButtons = [...document.querySelectorAll("[data-gallery-scroll]")];
    const photo = document.getElementById("gallery-photo");
    const caption = document.getElementById("gallery-photo-caption");
    const count = document.getElementById("gallery-photo-count");
    const previous = galleryViewer.querySelector("[data-gallery-prev]");
    const next = galleryViewer.querySelector("[data-gallery-next]");
    let currentIndex = 0;

    const updateScrollButtons = () => {
        const end = galleryTrack.scrollWidth - galleryTrack.clientWidth;
        scrollButtons.forEach((button) => {
            button.disabled = Number(button.dataset.galleryScroll) < 0
                ? galleryTrack.scrollLeft <= 2
                : galleryTrack.scrollLeft >= end - 2;
        });
    };

    const showPhoto = (index) => {
        currentIndex = index;
        photo.src = items[index].href;
        photo.alt = items[index].querySelector("img").alt;
        caption.textContent = photo.alt;
        count.textContent = `${index + 1} / ${items.length}`;
        previous.disabled = index === 0;
        next.disabled = index === items.length - 1;
    };

    items.forEach((item, index) => {
        item.addEventListener("click", (event) => {
            if (event.ctrlKey || event.metaKey || event.shiftKey || event.altKey) return;
            event.preventDefault();
            showPhoto(index);
            galleryViewer.showModal();
            document.body.classList.add("modal-open");
        });
    });

    previous.addEventListener("click", () => {
        if (currentIndex > 0) showPhoto(currentIndex - 1);
    });
    next.addEventListener("click", () => {
        if (currentIndex < items.length - 1) showPhoto(currentIndex + 1);
    });
    galleryViewer.addEventListener("keydown", (event) => {
        if (event.key === "ArrowLeft" && currentIndex > 0) {
            event.preventDefault();
            showPhoto(currentIndex - 1);
        } else if (event.key === "ArrowRight" && currentIndex < items.length - 1) {
            event.preventDefault();
            showPhoto(currentIndex + 1);
        }
    });
    scrollButtons.forEach((button) => {
        button.addEventListener("click", () => {
            galleryTrack.scrollBy({
                left: Number(button.dataset.galleryScroll) * galleryTrack.clientWidth * .8,
                behavior: window.matchMedia("(prefers-reduced-motion: reduce)").matches ? "auto" : "smooth"
            });
        });
    });
    galleryTrack.addEventListener("scroll", updateScrollButtons, { passive: true });
    new ResizeObserver(updateScrollButtons).observe(galleryTrack);
    updateScrollButtons();
}
