#!/bin/bash

# setup_cron.sh - Setup cron jobs for post scheduling and publishing

echo "Setting up cron jobs for RL Emily post scheduler..."

# Get the absolute path to the project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_PATH="$PROJECT_DIR/post_scheduler.py"

# Check if Python is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 is not installed or not in PATH"
    exit 1
fi

# Check if the script exists
if [ ! -f "$SCRIPT_PATH" ]; then
    echo "❌ post_scheduler.py not found at $SCRIPT_PATH"
    exit 1
fi

echo "📍 Project directory: $PROJECT_DIR"
echo "📄 Script path: $SCRIPT_PATH"

# Create cron job entries
# Schedule job runs at 5 AM IST daily (11 PM UTC the previous day, since IST is UTC+5:30)
# Posting job runs every 15 minutes to check for scheduled posts ready to publish

CRON_ENTRIES="
# RL Emily Post Scheduler - runs at 5 AM IST daily (11 PM UTC previous day)
0 23 * * * cd $PROJECT_DIR && python3 post_scheduler.py schedule >> $PROJECT_DIR/logs/scheduler.log 2>&1

# RL Emily Post Publisher - runs every 15 minutes to publish scheduled content
*/15 * * * * cd $PROJECT_DIR && python3 post_scheduler.py post >> $PROJECT_DIR/logs/publisher.log 2>&1
"

# Create logs directory
mkdir -p "$PROJECT_DIR/logs"

echo "📝 Adding cron jobs..."
echo "Current crontab:"
crontab -l 2>/dev/null || echo "(no existing crontab)"

# Backup existing crontab
crontab -l > "$PROJECT_DIR/crontab_backup_$(date +%Y%m%d_%H%M%S).txt" 2>/dev/null || echo "No existing crontab to backup"

# Add new cron jobs (avoid duplicates)
if crontab -l 2>/dev/null | grep -q "post_scheduler.py"; then
    echo "⚠️  Cron jobs already exist. Please check manually."
    echo "Current crontab:"
    crontab -l
else
    (crontab -l 2>/dev/null; echo "$CRON_ENTRIES") | crontab -
    echo "✅ Cron jobs added successfully!"
    echo "New crontab:"
    crontab -l
fi

echo ""
echo "🎯 Setup complete!"
echo ""
echo "Cron jobs configured:"
echo "1. 📅 Scheduling job: Runs at 5 AM IST (11 PM UTC) daily"
echo "   - Finds posts with status 'generated'"
echo "   - Changes status to 'scheduled'"
echo ""
echo "2. 🚀 Publishing job: Runs every 15 minutes"
echo "   - Finds scheduled posts ready to publish"
echo "   - Posts to social media platforms"
echo "   - Updates status to 'posted' with media_id"
echo ""
echo "📊 Logs are stored in: $PROJECT_DIR/logs/"
echo "   - scheduler.log: Scheduling job logs"
echo "   - publisher.log: Publishing job logs"
echo ""
echo "To view cron logs:"
echo "  tail -f $PROJECT_DIR/logs/scheduler.log"
echo "  tail -f $PROJECT_DIR/logs/publisher.log"
echo ""
echo "To edit/remove cron jobs:"
echo "  crontab -e"
echo "  crontab -r  # Remove all cron jobs"
