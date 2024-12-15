**README: Bibliora Digital Library**

---

### Overview

Bibliora is a digital library application designed to help users manage their personal libraries, borrow books, and explore available titles. Due to time constraints and the loss of a team member during development, several features initially planned have not been implemented.

---

### Features

- Add books to your digital library.
- Manage your personal collection.
- Download and borrow books (conceptual, not fully implemented).
- Locate your books with a buzzer and a LED
- Scan your Book with a Scanner to add it to your Reading List

---

### Installation and Setup

No installation is required for the app. However, the following backend infrastructure must be running:

1. AWS RDS Database:

   - Ensure the database is active and accessible.
   - It may go offline due to AWS free-tier limitations.

2. AWS EC2 Instance:

   - The EC2 instance hosting the backend must be running.

### Access the Application:

- Visit: [Bibliora Website](https://bibliora.online)
- Visit: [Bibliora Backend](https://bibliorabackend.online)
- Important: For optimal experience, use a desktop or large screen.

---

### Known Bugs and Issues

1. Screen Size Compatibility:

   - Many UI elements are hardcoded due to time constraints, leading to display issues on smaller screens.
   - Workaround: Use a large screen or desktop for the best experience.

2. Google Integration Issues:

   - Google login is not functioning as intended on the frontend.
   - This is due to incorrect handling of JWT tokens between the backend and frontend.

3. Access Manager and PubNub:

   - These were planned but could not be implemented due to time constraints.

4. Code Quality Issues:

   - There is duplicate code and excessive code within single files, making it difficult to maintain and enhance the application.

---

### Planned Features (Not Implemented)

- Fully functional borrowing and downloading of books.
- Responsive UI to support all screen sizes.
- Access Manager and PubNub integration for better user experience.
- Enhanced code quality, removing redundancy and adhering to best practices.
