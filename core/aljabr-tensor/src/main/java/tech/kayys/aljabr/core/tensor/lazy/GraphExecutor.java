package tech.kayys.aljabr.core.tensor.lazy;

import tech.kayys.aljabr.core.backend.ComputeBackend;
import tech.kayys.aljabr.core.tensor.Tensor;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Topologically sorts and evaluates a GraphNode DAG.
 */
public class GraphExecutor {

    private final ComputeBackend backend;

    public GraphExecutor(ComputeBackend backend) {
        this.backend = backend;
    }

    public Tensor evaluate(GraphNode root) {
        if (root.isEvaluated()) {
            return root.getMaterializedData();
        }

        List<GraphNode> topoOrder = new ArrayList<>();
        Set<GraphNode> visited = new HashSet<>();
        
        buildTopoOrder(root, visited, topoOrder);
        
        for (GraphNode node : topoOrder) {
            if (!node.isEvaluated()) {
                Tensor result = executeNode(node);
                node.setMaterializedData(result);
            }
        }
        
        return root.getMaterializedData();
    }

    private void buildTopoOrder(GraphNode node, Set<GraphNode> visited, List<GraphNode> topoOrder) {
        if (visited.contains(node)) return;
        visited.add(node);
        
        for (GraphNode input : node.getInputs()) {
            buildTopoOrder(input, visited, topoOrder);
        }
        
        topoOrder.add(node);
    }

    private Tensor executeNode(GraphNode node) {
        List<GraphNode> inputs = node.getInputs();
        Object[] args = node.getArgs();

        return switch (node.getOp()) {
            case CONSTANT -> throw new IllegalStateException("CONSTANT node should already be evaluated.");
            
            // Arithmetic
            case ADD -> backend.add(inputs.get(0).getMaterializedData(), inputs.get(1).getMaterializedData());
            case SUB -> backend.sub(inputs.get(0).getMaterializedData(), inputs.get(1).getMaterializedData());
            case MUL -> backend.mul(inputs.get(0).getMaterializedData(), inputs.get(1).getMaterializedData());
            case DIV -> backend.div(inputs.get(0).getMaterializedData(), inputs.get(1).getMaterializedData());
            case ADD_SCALAR -> backend.addScalar(inputs.get(0).getMaterializedData(), (float) args[0]);
            case MUL_SCALAR -> backend.mul(inputs.get(0).getMaterializedData(), (float) args[0]);
            case DIV_SCALAR -> backend.div(inputs.get(0).getMaterializedData(), (float) args[0]);
            
            // Matmul
            case MATMUL -> backend.matmul(inputs.get(0).getMaterializedData(), inputs.get(1).getMaterializedData());
            
            // Shape
            case RESHAPE -> backend.reshape(inputs.get(0).getMaterializedData(), (long[]) args[0]);
            
            // Activations
            case RELU -> backend.relu(inputs.get(0).getMaterializedData());
            case SILU -> backend.silu(inputs.get(0).getMaterializedData());
            
            // And more operations as needed. 
            // In a production codebase, this switch would exhaustively cover OpType.
            default -> throw new UnsupportedOperationException("GraphExecutor does not yet support op: " + node.getOp());
        };
    }
}
