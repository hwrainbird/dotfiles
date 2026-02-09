#!/usr/bin/env python3

import sys
import json
import os
from datetime import datetime

def load_template():
    """Load the note template from file"""
    template_path = os.path.expanduser('~/.config/task/templates/task-note-template.md')
    
    try:
        with open(template_path, 'r') as f:
            return f.read()
    except FileNotFoundError:
        # Fallback template if file doesn't exist
        return """# {description}

**Ticket ID**: {ticket_id}
**UUID**: {uuid}
**Project**: {project}
**Created**: {created_date}

## Description

## Attachments

## Action Items
- [ ] Review task details
- [ ] Update task status when complete

## Notes
"""

def create_task_notes(task_data):
    """Create task notes file for a new task"""
    
    # Get the task details
    uuid = task_data.get('uuid', '')
    ticket_id = task_data.get('ticketid', '')
    description = task_data.get('description', '')
    project = task_data.get('project', 'general')
    
    if not uuid:
        return task_data  # No UUID, nothing to do
    
    # Ensure notes directory exists
    notes_dir = '/Users/knack/notes/task_notes'
    os.makedirs(notes_dir, exist_ok=True)
    
    # Ticket ID is assigned by on-add.assign-ticketid hook
    # If still missing (hook disabled?), skip note creation
    if not ticket_id:
        return task_data
    
    # Always use ticket ID for filename (consistent naming)
    notes_file = f"{notes_dir}/{ticket_id}.md"
    
    # Only create notes if file doesn't exist
    if not os.path.exists(notes_file):
        # Load and process template
        template = load_template()
        created_date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        
        # Replace template variables
        note_content = template.format(
            description=description,
            ticket_id=ticket_id,
            uuid=uuid,
            project=project,
            created_date=created_date
        )
        
        with open(notes_file, 'w') as f:
            f.write(note_content)
    
    # Add annotation with the notes file path
    if 'annotations' not in task_data:
        task_data['annotations'] = []
    
    # Add the file path annotation
    task_data['annotations'].append({
        'entry': task_data.get('entry', ''),
        'description': notes_file
    })
    
    return task_data

def main():
    """Main function to handle taskwarrior hook interface"""
    # Read the new task from stdin
    task_data = json.loads(sys.stdin.read())
    
    # Create notes and modify task data
    modified_task = create_task_notes(task_data)
    
    # Output the modified task
    print(json.dumps(modified_task))

if __name__ == '__main__':
    main()