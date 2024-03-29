# MongoDB Container Hardening Workflow

A workflow for hardening a MongoDB container against a STIG using Packer and Ansible, including a scanning step and a threshold validation step to verify compliance.

## Dependencies

- [Docker](https://docs.docker.com/) - Container engine.
- [Packer](https://developer.hashicorp.com/packer) - A container image builder tool.
- [Ansible](https://docs.ansible.com/) - An orchestration tool that can target containers. Used as the provisioner to STIG-harden the container under Packer's direction.
- Progress Chef's [InSpec](https://docs.chef.io/inspec/) testing framework.
- [SAF CLI](https://saf-cli.mitre.org) for validating the results of the InSpec scan against a defined threshold (e.g. "95% of tests pass", or "no high-severity failures")

## Usage

1. **Clone the Repository**

   Start by cloning the `mongo-hardening` repository from GitHub to your local machine. Use the following command in your terminal:

   ```
   https://github.com/mitre/mongo-hardening.git
   cd mongo-hardening
   ```

2. **Initialize Packer**

   Initialize Packer to install the required Ansible and Docker plugins. Run the following command:

   ```
   packer init .
   ```

3. **Build the Hardened Image**

   Execute the following command to build, test, and save the hardened Mongo image:

   ```
   packer build mongo-hardening.pkr.hcl
   ```

4. **Run the Hardened Image**

   Execute the following command to run the hardened Mongo image:

   ```
   docker run -d -p 27017:27017 -v mongodb_configdb:/data/configdb -v mongodb_db:/data/db mongo-hardened --config /etc/mongod.conf
   ```

## Notes

- You can add additional types of scanning beyond InSpec (or get InSpec to run more than one testing profile) by modifying the `scripts/scan.sh` file. See the [MITRE SAF(c) Validation Library](https://saf.mitre.org/#/validate) for more InSpec profiles, or use your favorite image scanning tool.

- The `verify_threshold.sh` script will tag the generated image as "passing" if it exceeds the compliance threshold set in `threshold.yml`, and "failing" if it does not. A real hardening pipeline would instead do something like push an image that passes the threshold to a registry, and simply ignore it if it does not.

- To run the inspec seperately
  - Remove the `--controls` flag to run all inspec checks at once.
  ```
  inspec exec spec/mongo-inspec-profile/ -t docker://image_name --controls=SV-252134 --input-file=spec/mongo-inspec-profile/inputs.yml
  ```

---
