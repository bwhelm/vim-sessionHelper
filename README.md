`vim-sessionHelper` is designed to help with the creation and management of sessions. It distinguishes between three kinds of sessions:

1. **Ad hoc sessions**, which the user can create, open (and modify or delete) as needed via the commands below. These sessions are stored in files prefixed by "adhoc-", though that prefix is abstracted away from the user.

2. **Permament sessions**, which are vimscript files located in the `sessions` directory. They can only be *opened* via the `:SessionOpen` command. As an example, the file `~/.vim/sessions/v.vim` might contain:

    > edit ~/.vim
    > lcd ~/.vim

    This will open the vim directory in netrw and cd to that directory. This is handy for jumping around to frequently used directories within vim.

3. **Autosaved sessions**, which can be automatically created (and deleted) via autocommands, saving a snapshot of the current vim session. These session files cannot be manually saved, but they can be opened and deleted via the commands below.

# Commands

The following commands do the mostly obvious things:

1. `:SessionOpen`

2. `:SessionSave`

3. `:SessionDelete`

4. `:SessionOpenDelete`: this will open a session file and simultaneously delete it in one step.

Note that you can use command-line completion on ad-hoc session names, and that issuing the command with no argument will present a list of all sessions (including permanent sessions) to choose from.

# Customization

## Suggested Mappings

I suggest the following mappings for easy access. (Note that each one has a single trailing space.)
- nnoremap <LocalLeader>so :SessionOpen 
- nnoremap <LocalLeader>ss :SessionSave 
- nnoremap <LocalLeader>sd :SessionDelete 
- nnoremap <LocalLeader>sO :SessionOpenDelete 

## Variables

There is one variable that determines the location of mappings, which by default is set as follows:

- let g:sessionHelperDirectory = expand("$HOME") . "/.vim/sessions/"

If the specified directory does not currently exist, it will be created.
