import java.io.*;
import java.util.*;

class Main {
    public static void main(String[] args) throws IOException {
        String inputFile = "input.txt";
        int connectionCount = 1000;
        Box[] boxes = new BufferedReader(new FileReader(inputFile))
            .lines()
            .map(line -> new Box(line))
            .toArray(size -> new Box[size]);

        ArrayList<BoxPair> pairs = new ArrayList<>();
        for (int i = 0; i < boxes.length; ++i) {
            for (int j = i + 1; j < boxes.length; ++j) {
                if (i == j) continue;
                pairs.add(new BoxPair(i, j, boxes[i].distanceSquaredTo(boxes[j])));
            }
        }
        Collections.sort(pairs);

        Graph g = new Graph(pairs, boxes.length, connectionCount);

        // part one
        int product = 1;
        for (int i = 0; i < 3; i++) product *= g.componentSizes.get(i);

        // part two
        while (!g.isFullyConnected()) {
            g.addConnection(pairs.get(connectionCount++));
        }
        BoxPair last = pairs.get(connectionCount - 1);
        long finalXDistance = boxes[last.a].x * boxes[last.b].x;

        System.out.println("Part one: " + product);
        System.out.println("Part two: " + finalXDistance);
    }
}

class Graph {
    int vertexCount;
    List<List<Integer>> adj;
    List<Integer> componentSizes;
    int componentCount;

    public Graph(List<BoxPair> pairs, int vertexCount, int connectionCount) {
        this.vertexCount = vertexCount;
        adj = new ArrayList<List<Integer>>(vertexCount);
        for (int i = 0; i < vertexCount; ++i) {
            adj.add(new ArrayList<Integer>());
        }
        for (int i = 0; i < connectionCount; ++i) {
            addConnection(pairs.get(i));
        }

        componentSizes = new ArrayList<>();
        countComponentSizes();
    }

    public void addConnection(BoxPair pair) {
        adj.get(pair.a).add(pair.b);
        adj.get(pair.b).add(pair.a);
    }

    public boolean isFullyConnected() {
        boolean[] visited = new boolean[vertexCount];
        dfs(0, visited);
        for (boolean b : visited) if (!b) return false;
        return true;
    }

    public void countComponentSizes() {
        componentCount = 0;
        int vertexCount = adj.size();
        boolean[] visited = new boolean[vertexCount];
        componentSizes.clear();
        componentSizes.add(0);
        for (int i = 0; i < vertexCount; ++i) {
            if (!visited[i]) {
                dfs(i, visited);
                componentCount++;
                componentSizes.add(0);
            }
        }
        // this is so stupid
        Collections.sort(componentSizes, Collections.reverseOrder());
    }

    private void dfs(int v, boolean[] visited) {
        visited[v] = true;
        int size = componentSizes.get(componentCount);
        componentSizes.set(componentCount, size + 1);
        for (int i : adj.get(v)) {
            if (!visited[i]) {
                dfs(i, visited);
            }
        }
    }
}

class Box {
    long x, y, z;
    public Box(String line) {
        String[] toks = line.split(",");
        this.x = Long.parseLong(toks[0]);
        this.y = Long.parseLong(toks[1]);
        this.z = Long.parseLong(toks[2]);
    }

    public long distanceSquaredTo(Box other) {
        long dx = other.x - x, dy = other.y - y, dz = other.z - z;
        return dx*dx + dy*dy + dz*dz;
    }

    @Override
    public String toString() {
        return String.format("{%d, %d, %d}", x, y, z);
    }
}

// stores ids/vertex of the boxes into the adj list
class BoxPair implements Comparable<BoxPair> {
    int a, b;
    long distanceSquared;
    public BoxPair(int a, int b, long distanceSquared) {
        this.a = a;
        this.b = b;
        this.distanceSquared = distanceSquared;
    }

    @Override
    public int compareTo(BoxPair other) {
        if (distanceSquared < other.distanceSquared) return -1;
        if (distanceSquared > other.distanceSquared) return 1;
        return 0;
    }
} 
