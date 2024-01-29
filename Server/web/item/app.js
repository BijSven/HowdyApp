const sections = document.querySelectorAll("section");
let currentIndex = 0;
let isScrolling = false;
let tempSection = null;

function createTempSection() {
    let tempSection = document.createElement("section");
    var color = getRandomColor();
    tempSection.style.position = "absolute";
    tempSection.style.top = "0";
    tempSection.style.left = "0";
    tempSection.style.padding = "0";
    tempSection.style.margin = "0";
    tempSection.style.width = "100vw";
    tempSection.style.height = "100vh";
    tempSection.style.zIndex = "9999";
    tempSection.style.backgroundColor = color;
    tempSection.style.opacity = "0";
    tempSection.style.transition = "opacity 250ms ease-in-out";
    tempSection.style.display = "flex";
    tempSection.style.alignItems = "center";
    tempSection.style.justifyContent = "center";
    tempSection.style.color = "white";
    tempSection.style.fontSize = "calc(1.5vw + 1.5vh)";
    tempSection.style.fontWeight = "bold";
    tempSection.classList.add("temp-section");

    document.body.appendChild(tempSection);
    return tempSection;
}

function handleScroll(event) {
    if(document.querySelectorAll('.temp-section').length > 0) {
        event.preventDefault();
        return;
    }    

    event.preventDefault();

    const delta = event.deltaY;
    const nextIndex = currentIndex + (delta > 0 ? 1 : -1);

    if (nextIndex >= 0 && nextIndex < sections.length) {
        const currentSection = sections[currentIndex];
        const nextSection = sections[nextIndex];

        if (tempSection) {
            tempSection.remove();
        }

        tempSection = createTempSection();

        const sectionName = nextSection.id
            .split("-")
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(" ");

        tempSection.innerText = sectionName;
        tempSection.style.top = nextSection.offsetTop + "px";
        tempSection.style.opacity = 1;

        setTimeout(() => {
            tempSection.style.opacity = 0;
            currentIndex = nextIndex;
            setTimeout(() => {
                tempSection.remove();
            }, 250);
        }, 600);

        window.scrollTo({
            top: nextSection.offsetTop,
            behavior: "smooth"
        });
    }
}

window.addEventListener("wheel", handleScroll, { passive: false });

function getRandomColor() {
    const letters = "0123456789ABCDEF";
    let color = "#";
    for (let i = 0; i < 6; i++) {
        color += letters[Math.floor(Math.random() * 16)];
    }
    return color;
}