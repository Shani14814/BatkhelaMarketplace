<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    echo json_encode(['ok' => true]);
    exit;
}

$dbHost = 'localhost';
$dbName = 'u391670910_batkhela';
$dbUser = 'u391670910_btkusr';
$dbPass = getenv('BATKHELA_DB_PASS') ?: 'YOUR_DB_PASSWORD';

try {
    $pdo = new PDO(
        "mysql:host={$dbHost};dbname={$dbName};charset=utf8mb4",
        $dbUser,
        $dbPass,
        [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]
    );
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => 'Database connection failed: ' . $e->getMessage()]);
    exit;
}

// Ensure tables exist
$pdo->exec("
CREATE TABLE IF NOT EXISTS btk_stores (
    id VARCHAR(64) PRIMARY KEY,
    sort_order INT NOT NULL DEFAULT 999,
    data_json LONGTEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS btk_products (
    id VARCHAR(64) PRIMARY KEY,
    vendor_id VARCHAR(64) NOT NULL,
    data_json LONGTEXT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_vendor (vendor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS btk_orders (
    id VARCHAR(64) PRIMARY KEY,
    order_number INT NOT NULL DEFAULT 1000,
    vendor_id VARCHAR(64) NOT NULL DEFAULT 'store-1',
    status VARCHAR(32) NOT NULL DEFAULT 'placed',
    data_json LONGTEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_vendor (vendor_id),
    INDEX idx_order_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS btk_rider_telemetry (
    id VARCHAR(64) PRIMARY KEY,
    rider_lat DOUBLE NOT NULL DEFAULT 34.6194,
    rider_lng DOUBLE NOT NULL DEFAULT 71.9735,
    rider_heading DOUBLE NOT NULL DEFAULT 0.0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
");

$action = $_GET['action'] ?? 'state';
$rawBody = file_get_contents('php://input');
$body = !empty($rawBody) ? json_decode($rawBody, true) : [];
if (!is_array($body)) {
    $body = [];
}

try {
    if ($action === 'state') {
        $storesRows = $pdo->query("SELECT data_json FROM btk_stores ORDER BY sort_order ASC, id ASC")->fetchAll();
        $productsRows = $pdo->query("SELECT data_json FROM btk_products ORDER BY updated_at DESC, id ASC")->fetchAll();
        $ordersRows = $pdo->query("SELECT data_json FROM btk_orders ORDER BY created_at DESC, id DESC")->fetchAll();
        $riderRow = $pdo->query("SELECT rider_lat, rider_lng, rider_heading, updated_at FROM btk_rider_telemetry WHERE id = 'rider_main' LIMIT 1")->fetch();

        if (!$riderRow) {
            $riderRow = [
                'rider_lat' => 34.6194,
                'rider_lng' => 71.9735,
                'rider_heading' => 45.0,
                'updated_at' => gmdate('c'),
            ];
        } else {
            $riderRow['rider_lat'] = (float)$riderRow['rider_lat'];
            $riderRow['rider_lng'] = (float)$riderRow['rider_lng'];
            $riderRow['rider_heading'] = (float)$riderRow['rider_heading'];
        }

        $stores = [];
        foreach ($storesRows as $r) {
            $decoded = json_decode($r['data_json'], true);
            if (is_array($decoded)) $stores[] = $decoded;
        }

        $products = [];
        foreach ($productsRows as $r) {
            $decoded = json_decode($r['data_json'], true);
            if (is_array($decoded)) $products[] = $decoded;
        }

        $orders = [];
        foreach ($ordersRows as $r) {
            $decoded = json_decode($r['data_json'], true);
            if (is_array($decoded)) {
                if (($decoded['status'] ?? '') === 'out_for_delivery') {
                    if (!isset($decoded['rider_lat'])) $decoded['rider_lat'] = $riderRow['rider_lat'];
                    if (!isset($decoded['rider_lng'])) $decoded['rider_lng'] = $riderRow['rider_lng'];
                }
                $orders[] = $decoded;
            }
        }

        echo json_encode([
            'ok' => true,
            'seeded' => count($stores) > 0,
            'stores' => $stores,
            'products' => $products,
            'orders' => $orders,
            'rider_telemetry' => $riderRow,
            'server_time' => gmdate('c'),
        ]);
        exit;
    }

    if ($action === 'seed') {
        $stores = $body['stores'] ?? [];
        $products = $body['products'] ?? [];
        $orders = $body['orders'] ?? [];

        $pdo->beginTransaction();

        if (is_array($stores)) {
            $stmtStore = $pdo->prepare("
                INSERT IGNORE INTO btk_stores (id, sort_order, data_json)
                VALUES (:id, :sort_order, :data_json)
            ");
            foreach ($stores as $idx => $s) {
                if (!empty($s['id'])) {
                    $stmtStore->execute([
                        ':id' => (string)$s['id'],
                        ':sort_order' => (int)$idx,
                        ':data_json' => json_encode($s, JSON_UNESCAPED_UNICODE),
                    ]);
                }
            }
        }

        if (is_array($products)) {
            $stmtProd = $pdo->prepare("
                INSERT IGNORE INTO btk_products (id, vendor_id, data_json)
                VALUES (:id, :vendor_id, :data_json)
            ");
            foreach ($products as $p) {
                if (!empty($p['id'])) {
                    $stmtProd->execute([
                        ':id' => (string)$p['id'],
                        ':vendor_id' => (string)($p['vendor_id'] ?? 'store-1'),
                        ':data_json' => json_encode($p, JSON_UNESCAPED_UNICODE),
                    ]);
                }
            }
        }

        if (is_array($orders)) {
            $stmtOrd = $pdo->prepare("
                INSERT IGNORE INTO btk_orders (id, order_number, vendor_id, status, data_json)
                VALUES (:id, :order_number, :vendor_id, :status, :data_json)
            ");
            foreach ($orders as $o) {
                if (!empty($o['id'])) {
                    $stmtOrd->execute([
                        ':id' => (string)$o['id'],
                        ':order_number' => (int)($o['order_number'] ?? 1000),
                        ':vendor_id' => (string)($o['vendor_id'] ?? 'store-1'),
                        ':status' => (string)($o['status'] ?? 'placed'),
                        ':data_json' => json_encode($o, JSON_UNESCAPED_UNICODE),
                    ]);
                }
            }
        }

        $pdo->commit();
        echo json_encode(['ok' => true, 'message' => 'Seed completed']);
        exit;
    }

    if ($action === 'save_store') {
        $store = $body['store'] ?? $body;
        $id = (string)($store['id'] ?? '');
        if ($id === '') {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => 'Missing store id']);
            exit;
        }
        $sortOrder = (int)($store['sort_order'] ?? 99);
        $stmt = $pdo->prepare("
            INSERT INTO btk_stores (id, sort_order, data_json)
            VALUES (:id, :sort_order, :data_json)
            ON DUPLICATE KEY UPDATE data_json = VALUES(data_json)
        ");
        $stmt->execute([
            ':id' => $id,
            ':sort_order' => $sortOrder,
            ':data_json' => json_encode($store, JSON_UNESCAPED_UNICODE),
        ]);
        echo json_encode(['ok' => true, 'id' => $id]);
        exit;
    }

    if ($action === 'save_product') {
        $product = $body['product'] ?? $body;
        $id = (string)($product['id'] ?? '');
        if ($id === '') {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => 'Missing product id']);
            exit;
        }
        $vendorId = (string)($product['vendor_id'] ?? 'store-1');
        $stmt = $pdo->prepare("
            INSERT INTO btk_products (id, vendor_id, data_json)
            VALUES (:id, :vendor_id, :data_json)
            ON DUPLICATE KEY UPDATE vendor_id = VALUES(vendor_id), data_json = VALUES(data_json)
        ");
        $stmt->execute([
            ':id' => $id,
            ':vendor_id' => $vendorId,
            ':data_json' => json_encode($product, JSON_UNESCAPED_UNICODE),
        ]);
        echo json_encode(['ok' => true, 'id' => $id]);
        exit;
    }

    if ($action === 'delete_product') {
        $id = (string)($body['id'] ?? $_GET['id'] ?? '');
        if ($id === '') {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => 'Missing product id']);
            exit;
        }
        $stmt = $pdo->prepare("DELETE FROM btk_products WHERE id = :id");
        $stmt->execute([':id' => $id]);
        echo json_encode(['ok' => true, 'deleted_id' => $id]);
        exit;
    }

    if ($action === 'place_order') {
        $order = $body['order'] ?? $body;
        $id = (string)($order['id'] ?? '');
        if ($id === '') {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => 'Missing order id']);
            exit;
        }
        $orderNumber = (int)($order['order_number'] ?? 1000);
        $vendorId = (string)($order['vendor_id'] ?? 'store-1');
        $status = (string)($order['status'] ?? 'placed');

        $stmt = $pdo->prepare("
            INSERT INTO btk_orders (id, order_number, vendor_id, status, data_json)
            VALUES (:id, :order_number, :vendor_id, :status, :data_json)
            ON DUPLICATE KEY UPDATE status = VALUES(status), data_json = VALUES(data_json)
        ");
        $stmt->execute([
            ':id' => $id,
            ':order_number' => $orderNumber,
            ':vendor_id' => $vendorId,
            ':status' => $status,
            ':data_json' => json_encode($order, JSON_UNESCAPED_UNICODE),
        ]);
        echo json_encode(['ok' => true, 'id' => $id]);
        exit;
    }

    if ($action === 'update_order_status') {
        $id = (string)($body['id'] ?? '');
        $status = (string)($body['status'] ?? '');
        if ($id === '' || $status === '') {
            http_response_code(400);
            echo json_encode(['ok' => false, 'error' => 'Missing id or status']);
            exit;
        }
        $stmtGet = $pdo->prepare("SELECT data_json FROM btk_orders WHERE id = :id");
        $stmtGet->execute([':id' => $id]);
        $row = $stmtGet->fetch();
        if (!$row) {
            http_response_code(404);
            echo json_encode(['ok' => false, 'error' => 'Order not found']);
            exit;
        }
        $orderData = json_decode($row['data_json'], true);
        if (!is_array($orderData)) $orderData = ['id' => $id];
        $orderData['status'] = $status;
        if (isset($body['rider_lat'])) $orderData['rider_lat'] = (float)$body['rider_lat'];
        if (isset($body['rider_lng'])) $orderData['rider_lng'] = (float)$body['rider_lng'];
        if (isset($body['rider_heading'])) $orderData['rider_heading'] = (float)$body['rider_heading'];
        if (isset($body['assigned_rider_id'])) $orderData['assigned_rider_id'] = (string)$body['assigned_rider_id'];
        if (isset($body['assigned_rider_name'])) $orderData['assigned_rider_name'] = (string)$body['assigned_rider_name'];
        if (isset($body['delivery_assignment_type'])) $orderData['delivery_assignment_type'] = (string)$body['delivery_assignment_type'];
        $orderData['updated_at'] = gmdate('c');

        $stmtUpd = $pdo->prepare("
            UPDATE btk_orders
            SET status = :status, data_json = :data_json
            WHERE id = :id
        ");
        $stmtUpd->execute([
            ':status' => $status,
            ':data_json' => json_encode($orderData, JSON_UNESCAPED_UNICODE),
            ':id' => $id,
        ]);

        if (isset($body['rider_lat']) && isset($body['rider_lng'])) {
            $stmtR = $pdo->prepare("
                INSERT INTO btk_rider_telemetry (id, rider_lat, rider_lng, rider_heading)
                VALUES ('rider_main', :lat, :lng, :hdg)
                ON DUPLICATE KEY UPDATE rider_lat = VALUES(rider_lat), rider_lng = VALUES(rider_lng), rider_heading = VALUES(rider_heading)
            ");
            $stmtR->execute([
                ':lat' => (float)$body['rider_lat'],
                ':lng' => (float)$body['rider_lng'],
                ':hdg' => (float)($body['rider_heading'] ?? 0.0),
            ]);
        }

        echo json_encode(['ok' => true, 'id' => $id, 'status' => $status]);
        exit;
    }

    if ($action === 'update_rider_location') {
        $lat = isset($body['rider_lat']) ? (float)$body['rider_lat'] : 34.6194;
        $lng = isset($body['rider_lng']) ? (float)$body['rider_lng'] : 71.9735;
        $hdg = isset($body['rider_heading']) ? (float)$body['rider_heading'] : 0.0;
        $orderId = (string)($body['order_id'] ?? '');

        $stmtR = $pdo->prepare("
            INSERT INTO btk_rider_telemetry (id, rider_lat, rider_lng, rider_heading)
            VALUES ('rider_main', :lat, :lng, :hdg)
            ON DUPLICATE KEY UPDATE rider_lat = VALUES(rider_lat), rider_lng = VALUES(rider_lng), rider_heading = VALUES(rider_heading)
        ");
        $stmtR->execute([
            ':lat' => $lat,
            ':lng' => $lng,
            ':hdg' => $hdg,
        ]);

        // Also update active out_for_delivery orders (or specific orderId)
        $rows = $pdo->query("SELECT id, data_json FROM btk_orders WHERE status = 'out_for_delivery' OR id = " . $pdo->quote($orderId))->fetchAll();
        $stmtUpd = $pdo->prepare("UPDATE btk_orders SET data_json = :data_json WHERE id = :id");
        foreach ($rows as $r) {
            $od = json_decode($r['data_json'], true);
            if (is_array($od)) {
                $od['rider_lat'] = $lat;
                $od['rider_lng'] = $lng;
                $od['rider_heading'] = $hdg;
                $stmtUpd->execute([
                    ':data_json' => json_encode($od, JSON_UNESCAPED_UNICODE),
                    ':id' => $r['id'],
                ]);
            }
        }

        echo json_encode(['ok' => true, 'rider_lat' => $lat, 'rider_lng' => $lng]);
        exit;
    }

    http_response_code(400);
    echo json_encode(['ok' => false, 'error' => 'Unknown action: ' . $action]);
} catch (Throwable $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    http_response_code(500);
    echo json_encode(['ok' => false, 'error' => $e->getMessage()]);
}


