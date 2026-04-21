## Integration with  Message Router Pattern Using WSO2 Integrator:BI

### Overview

The **Message Router** consumes a message from one channel and republishes it to a different channel depending on a set of conditions.
This integration is built using **WSO2 Integrator:BI** to showcase the ease of implementing such patterns within a low-code integration environment.

For more detailed information on the **Message Router** pattern, visit the [Message Router documentation](https://www.enterpriseintegrationpatterns.com/patterns/messaging/MessageRouter.html).

## Design View

The **Design View** visualizes the overall system structure. It shows how different components (filters) are connected through pipes, demonstrating the data flow and interaction between the independent processing steps in the pipeline.

![Design View](design-view.png)

## Integration Flow

![Flow Diagram](flow.png)

## Sequence Diagram

![Flow Diagram](sequence.png)

## Steps to Open with WSO2 Integrator:BI

Follow these steps to open the project and start working with the **Message Router** integration using **WSO2 Integrator:BI** in **VS Code**:

1. Clone the repository to your local machine by running the following command.
   ```bash
   git clone https://github.com/wso2/integration-samples.git
   ```
2. Open VS Code.
3. Once VS Code is opened, go to `File > Open Folder...`.
4. Navigate to the directory where you cloned the repository.
5. Select the project folder and open it.
