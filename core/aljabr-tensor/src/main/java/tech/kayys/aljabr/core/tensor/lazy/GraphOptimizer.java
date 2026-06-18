package tech.kayys.aljabr.core.tensor.lazy;

import java.util.HashMap;
import java.util.Map;

/**
 * Optimizes a computation DAG by applying fusion and rewrite rules.
 */
public class GraphOptimizer {

    /**
     * Optimizes the graph starting from the given root node.
     * 
     * @param root the root node of the computation graph
     * @return an optimized GraphNode
     */
    public static GraphNode optimize(GraphNode root) {
        Map<GraphNode, GraphNode> visited = new HashMap<>();
        return optimizeNode(root, visited);
    }

    private static GraphNode optimizeNode(GraphNode node, Map<GraphNode, GraphNode> memo) {
        if (memo.containsKey(node)) {
            return memo.get(node);
        }

        // Optimize inputs recursively
        var newInputs = node.getInputs().stream()
                .map(input -> optimizeNode(input, memo))
                .toList();

        // Very basic optimization rule: ADD(x, 0) -> x
        if (node.getOp() == OpType.ADD_SCALAR && node.getArgs().length == 1) {
            float scalar = (float) node.getArgs()[0];
            if (scalar == 0.0f) {
                memo.put(node, newInputs.get(0));
                return newInputs.get(0);
            }
        }
        
        // Return a potentially new node if inputs changed, or the same node if no rules match.
        // For simplicity in this initial implementation, we just return a new node if inputs changed.
        GraphNode optimized = new GraphNode(node.getOp(), newInputs, node.getArgs(), node.getOutputShape(), node.getOutputDType());
        if (node.isEvaluated()) {
            optimized.setMaterializedData(node.getMaterializedData());
        }
        
        memo.put(node, optimized);
        return optimized;
    }
}
