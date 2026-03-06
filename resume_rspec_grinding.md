# resume_rspec_grinding.md

Follow the instructions outlined in this document to guide the automated grinding process for the RSpec test suite.

1. Review the README.md for project setup and guidelines.
2. Start with settlement_spec.rb and identify the 3 remaining failures.
3. Run the test suite in Docker to replicate the environment.
4. Apply surgical fixes autonomously:
   - Check data/fixtures for missing or incorrect data.
   - Review associations in models for correctness.
   - Update expectations in the specs as necessary.
5. Validate each fix by running RSpec in Docker after each change.
6. Commit changes atomically, including updates to the failure count in CURRENT_STATUS.md.
7. Once settlement_spec.rb is green, proceed to environment_spec.rb and celestial_bodies_controller_spec.rb.
8. Continue to apply fixes and validate until the total failure count is below 50.
9. Update CURRENT_STATUS.md after each batch of changes to reflect the current state of the test suite.
10. Follow all phases in the task document to ensure compliance and thoroughness.