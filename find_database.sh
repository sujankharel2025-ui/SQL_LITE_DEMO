#!/bin/bash

echo "🔍 Searching for SQLite database..."
echo ""

# Find the database file
DB_PATH=$(find ~/Library/Developer/CoreSimulator -name "chat_database.db" 2>/dev/null | head -1)

if [ -z "$DB_PATH" ]; then
    echo "❌ Database not found!"
    echo ""
    echo "Please make sure:"
    echo "1. You've run the app at least once (flutter run)"
    echo "2. The app created the database"
    echo ""
    echo "Searching for any .db files in app directories..."
    find ~/Library/Developer/CoreSimulator/Devices -name "*.db" -path "*/chat_flutter/*" 2>/dev/null | head -5
else
    echo "✅ Database found at:"
    echo "$DB_PATH"
    echo ""
    echo "📊 Database info:"
    ls -lh "$DB_PATH"
    echo ""
    echo "🔍 Opening in SQLite browser..."
    echo ""
    echo "To view the database, run:"
    echo "sqlite3 \"$DB_PATH\""
    echo ""
    echo "Or copy to Desktop:"
    echo "cp \"$DB_PATH\" ~/Desktop/chat_database.db"
    echo ""
    
    # Try to open with sqlite3
    if command -v sqlite3 &> /dev/null; then
        echo "📋 Tables in database:"
        sqlite3 "$DB_PATH" ".tables"
        echo ""
        echo "📊 Messages table schema:"
        sqlite3 "$DB_PATH" ".schema messages"
        echo ""
        echo "📨 Number of messages:"
        sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM messages;"
        echo ""
        echo "💬 All messages:"
        sqlite3 "$DB_PATH" "SELECT id, text, sender, timestamp, isSynced FROM messages;"
    fi
fi
